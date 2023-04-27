use std::{
    env,
    fs::{self, File},
    io,
    path::Path,
    process::{self, Command},
};

use clap::CommandFactory;
use clap_complete::{generate_to, shells};

#[allow(dead_code)]
#[path = "src/app.rs"]
mod app;

// https://doc.rust-lang.org/cargo/reference/build-scripts.html

fn main() {
    // OUT_DIR is set by Cargo. It's where additional build artifacts are written
    // https://doc.rust-lang.org/cargo/reference/build-scripts.html#outputs-of-the-build-script

    let outdir = if env::var_os("SHELL_COMPLETIONS_DIR").is_some() {
        env::var_os("SHELL_COMPLETIONS_DIR").unwrap()
    } else {
        match env::var_os("OUT_DIR") {
            Some(outdir) => outdir,
            None => {
                eprintln!(
                "OUT_DIR environment variable not defined. \
                 Please file a bug: \
                 https://github.com/lmburns/<REPO>/issues/new"
            );
                process::exit(1);
            },
        }
    };

    fs::create_dir_all(&outdir).expect("failed to create dirs for OUT_DIR");

    // Create a stamp file. (This is used by CI to help find the OUT_DIR.)
    let stamp_path = Path::new(&outdir).join("<PROGRAM>-stamp");
    if let Err(err) = File::create(&stamp_path) {
        panic!("failed to write {}: {}", stamp_path.display(), err);
    }

    // ╭───────────────────────╮
    // │  Generate completions │
    // ╰───────────────────────╯

    // Method 1
    // ════════
    let mut app = app::app();
    app.gen_completions("rg", Shell::Bash, &outdir);
    app.gen_completions("rg", Shell::Fish, &outdir);
    app.gen_completions("rg", Shell::PowerShell, &outdir);
    app.gen_completions("rg", Shell::Zsh, &outdir);

    // Make the current git hash available to the build.
    if let Some(rev) = git_revision_hash() {
        println!("cargo:rustc-env=<PROGRAM>_BUILD_GIT_HASH={}", rev);
    }

    // Method 2
    // ════════
    // let mut app = cli::Args::command();
    // macro_rules! gen {
    //     ($shell:expr) => {{
    //         let path = generate_to(
    //             $shell, &mut app, // We need to specify what generator to use
    //             "rgr",    // We need to specify the bin name manually
    //             &outdir,  // We need to specify where to write to
    //         )
    //         .expect("failed to generate completion");
    //
    //         println!("cargo:warning=completion file generated: {:?}", path);
    //     }};
    // }
    //
    // gen!(shells::Bash);
    // gen!(shells::Elvish);
    // gen!(shells::Fish);
    // gen!(shells::PowerShell);
    // gen!(shells::Zsh);

    // ╭───────────────────╮
    // │  Generate manpage │
    // ╰───────────────────╯
    if let Err(err) = generate_manpage(&outdir) {
        eprintln!("failed to generate man page: {}", err);
    }
}

fn git_revision_hash() -> Option<String> {
    let result = Command::new("git")
        .args(&["rev-parse", "--short=10", "HEAD"])
        .output();
    result.ok().and_then(|output| {
        let v = String::from_utf8_lossy(&output.stdout).trim().to_string();
        if v.is_empty() {
            None
        } else {
            Some(v)
        }
    })
}

fn generate_manpage<P: AsRef<Path>>(outdir: P) -> io::Result<()> {
    // If asciidoctor isn't installed, don't do anything
    if let Err(err) = Command::new("asciidoctor").output() {
        eprintln!("Could not run 'asciidoctor' binary, skipping man page generation.");
        eprintln!("Error from running 'asciidoctor': {}", err);
        return legacy_generate_man_page::<P>(outdir);
    }

    let outdir = outdir.as_ref();
    let cwd = env::current_dir()?;
    let template_path = cwd.join("doc").join("<PROGRAM>.1.template");
    let txt_path = outdir.join("<PROGRAM>.1.txt");

    let mut tpl = String::new();
    File::open(&template_path)?.read_to_string(&mut tpl)?;
    // let options = formatted_options()?
    //     .replace("&#123;", "{")
    //     .replace("&#125;", "}");
    // tpl = tpl.replace("{OPTIONS}", &options);

    let githash = git_revision_hash();
    let githash = githash.as_ref().map(|x| &**x);
    tpl = tpl.replace("{VERSION}", &app::long_version(githash, false));

    File::create(&txt_path)?.write_all(tpl.as_bytes())?;
    let result = Command::new("asciidoctor")
        .arg("--doctype")
        .arg("manpage")
        .arg("--backend")
        .arg("manpage")
        .arg("--destination-dir")
        .arg(&outdir)
        .arg(&txt_path)
        .spawn()?
        .wait()?;

    if !result.success() {
        let msg = format!("'asciidoctor' failed with exit code {:?}", result.code());
        return Err(ioerr(msg));
    }
    Ok(())
}

fn legacy_generate_man_page<P: AsRef<Path>>(outdir: P) -> io::Result<()> {
    // If a2x isn't installed, then don't do anything
    if let Err(err) = Command::new("a2x").output() {
        eprintln!("Could not run 'a2x' binary, skipping man page generation.");
        eprintln!("Error from running 'a2x': {}", err);
        return Ok(());
    }

    let outdir = outdir.as_ref();
    let cwd = env::current_dir()?;
    let template_path = cwd.join("doc").join("<PROGRAM>.1.template");
    let txt_path = outdir.join("<PROGRAM>.1.txt");

    // let mut tpl = String::new();
    // File::open(&template_path)?.read_to_string(&mut tpl)?;
    // tpl = tpl.replace("{OPTIONS}", &formatted_options()?);

    let githash = git_revision_hash();
    let githash = githash.as_ref().map(|x| &**x);
    tpl = tpl.replace("{VERSION}", &app::long_version(githash, false));

    File::create(&txt_path)?.write_all(tpl.as_bytes())?;
    let result = process::Command::new("a2x")
        .arg("--no-xmllint")
        .arg("--doctype")
        .arg("manpage")
        .arg("--format")
        .arg("manpage")
        .arg("--destination-dir")
        .arg(&outdir)
        .arg(&txt_path)
        .spawn()?
        .wait()?;
    if !result.success() {
        let msg = format!("'a2x' failed with exit code {:?}", result.code());
        return Err(ioerr(msg));
    }
    Ok(())
}

// fn formatted_options() -> io::Result<String> {
//     let mut args = app::all_args_and_flags();
//     args.sort_by(|x1, x2| x1.name.cmp(&x2.name));
//
//     let mut formatted = vec![];
//     for arg in args {
//         if arg.hidden {
//             continue;
//         }
//         // ripgrep only has two positional arguments, and probably will only
//         // ever have two positional arguments, so we just hardcode them into
//         // the template.
//         if let app::RGArgKind::Positional { .. } = arg.kind {
//             continue;
//         }
//         formatted.push(formatted_arg(&arg)?);
//     }
//     Ok(formatted.join("\n\n"))
// }
//
// fn formatted_arg(arg: &RGArg) -> io::Result<String> {
//     match arg.kind {
//         RGArgKind::Positional { .. } => {
//             panic!("unexpected positional argument")
//         }
//         RGArgKind::Switch { long, short, multiple } => {
//             let mut out = vec![];
//
//             let mut header = format!("--{}", long);
//             if let Some(short) = short {
//                 header = format!("-{}, {}", short, header);
//             }
//             if multiple {
//                 header = format!("*{}* ...::", header);
//             } else {
//                 header = format!("*{}*::", header);
//             }
//             writeln!(out, "{}", header)?;
//             writeln!(out, "{}", formatted_doc_txt(arg)?)?;
//
//             Ok(String::from_utf8(out).unwrap())
//         }
//         RGArgKind::Flag { long, short, value_name, multiple, .. } => {
//             let mut out = vec![];
//
//             let mut header = format!("--{}", long);
//             if let Some(short) = short {
//                 header = format!("-{}, {}", short, header);
//             }
//             if multiple {
//                 header = format!("*{}* _{}_ ...::", header, value_name);
//             } else {
//                 header = format!("*{}* _{}_::", header, value_name);
//             }
//             writeln!(out, "{}", header)?;
//             writeln!(out, "{}", formatted_doc_txt(arg)?)?;
//
//             Ok(String::from_utf8(out).unwrap())
//         }
//     }
// }
//
// fn formatted_doc_txt(arg: &RGArg) -> io::Result<String> {
//     let paragraphs: Vec<String> = arg
//         .doc_long
//         .replace("{", "&#123;")
//         .replace("}", r"&#125;")
//         // Hack to render ** literally in man page correctly. We can't put
//         // these crazy +++ in the help text directly, since that shows
//         // literally in --help output.
//         .replace("*-g 'foo/**'*", "*-g +++'foo/**'+++*")
//         .split("\n\n")
//         .map(|s| s.to_string())
//         .collect();
//     if paragraphs.is_empty() {
//         return Err(ioerr(format!("missing docs for --{}", arg.name)));
//     }
//     let first = format!("  {}", paragraphs[0].replace("\n", "\n  "));
//     if paragraphs.len() == 1 {
//         return Ok(first);
//     }
//     Ok(format!("{}\n+\n{}", first, paragraphs[1..].join("\n+\n")))
// }

fn ioerr(msg: String) -> io::Error {
    io::Error::new(io::ErrorKind::Other, msg)
}
