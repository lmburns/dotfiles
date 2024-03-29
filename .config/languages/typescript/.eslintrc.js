// https://robertcooper.me/post/using-eslint-and-prettier-in-a-typescript-project
// https://stackoverflow.com/questions/61350494/eslint-rule-conflicts-with-prettier-rule

// https://github.com/gajus/eslint-plugin-jsdoc
// https://github.com/jsx-eslint/eslint-plugin-react

// @typescript-eslint/eslint-plugin
// @typescript-eslint/parser
// eslint
// eslint-plugin-prettier   // Runs prettier as an ESLint rule for JS
// eslint-config-prettier   // Disables ESLint rules that might conflict with prettier
// prettier
//
// jest
// eslint-plugin-jest
// https://github.com/gajus/eslint-plugin-jsdoc
// eslint-plugin-jsdoc
// eslint-plugin-react
// esbuild

module.exports = {
  root: true,
  env: {
    es2022: true,
    node: true,
    browser: true,
    es6: true,
    // commonjs: true,
  },
  extends: [
    'react-app',
    // 'plugin:@typescript-eslint/eslint-recommended',
    // 'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
    'plugin:jsdoc/recommended',
    'eslint:recommended',
    // 'plugin:prettier/recommended',
    'prettier',
  ],
  plugins: ['jsdoc', '@typescript-eslint', 'prettier'],
  // globals: {},
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    ecmaFeatures: {jsx: true},
  },
  rules: {
    // https://eslint.org/docs/latest/rules/

    'max-len': ['error', {code: 100, tabWidth: 4}],
    quotes: ['warn', 'single', {avoidEscape: true, allowTemplateLiterals: true}],
    'jsx-quotes': ['error', 'prefer-double'],
    semi: ['error', 'always', {omitLastInOneLineBlock: true}],
    'key-spacing': [
      'warn',
      {
        singleLine: {
          beforeColon: false,
          afterColon: true,
        },
        multiLine: {
          beforeColon: false,
          afterColon: true,
          align: 'value',
        },
      },
    ],

    // ╭─────────────────╮
    // │  Logic Problems │
    // ╰─────────────────╯
    'constructor-super': 'error',
    'for-direction': ['error'],
    'getter-return': ['error'],
    'no-async-promise-executor': [0],
    // 'no-await-in-loop': [],
    'no-class-assign': ['error'],
    'no-compare-neg-zero': ['error'],
    'no-cond-assign': ['error', 'except-parens'],
    'no-const-assign': ['error'],
    // 'no-constant-binary-expression': [],
    'no-constant-condition': ['error'],
    // 'no-constructor-return': [],
    'no-control-regex': ['error'],
    'no-debugger': 'error',
    'no-dupe-args': ['error'],
    'no-dupe-class-members': [0],
    // 'no-dupe-else-if': [],
    'no-dupe-keys': ['error'],
    'no-duplicate-case': ['error'],
    // 'no-duplicate-imports': [],
    'no-empty-character-class': ['error'],
    'no-empty-pattern': ['error'],
    'no-ex-assign': ['error'],
    'no-fallthrough': 'off',
    'no-func-assign': ['error'],
    // 'no-import-assign': [],
    'no-inner-declarations': ['error'],
    'no-invalid-regexp': ['error'],
    'no-irregular-whitespace': 'error',
    // 'no-loss-of-precision': '',
    'no-misleading-character-class': ['error'],
    // 'no-new-native-nonconstructor': [],
    'no-new-symbol': ['error'],
    'no-obj-calls': ['error'],
    // 'no-promise-executor-return': [],
    'no-prototype-builtins': [0],
    'no-self-assign': ['error'],
    // 'no-self-compare': [],
    // 'no-setter-return': [],
    'no-sparse-arrays': 'error',
    'no-template-curly-in-string': 'off',
    'no-this-before-super': ['error'],
    'no-undef': ['off'],
    'no-unexpected-multiline': ['error'],
    // 'no-unmodified-loop-condition': [],
    'no-unreachable': ['warn'],
    // 'no-unreachable-loop': [],
    'no-unsafe-finally': 'error',
    'no-unsafe-negation': ['error'],
    'no-unsafe-optional-chaining': ['error'],
    // 'no-unused-private-class-members': [],
    'no-unused-vars': 'off',
    // 'no-use-before-define': [],
    'no-useless-backreference': 'error',
    'require-atomic-updates': [0],
    'use-isnan': 'error',
    'valid-typeof': 'off',

    // ╭──────────────╮
    // │  Suggestions │
    // ╰──────────────╯
    'accessor-pairs': [
      'error',
      {
        getWithoutSet: true,
        setWithoutGet: true,
        enforceForClassMembers: false,
      },
    ],
    'arrow-body-style': 'off',
    // 'block-scoped-var': '',
    camelcase: 'off',
    'capitalized-comments': 'off',
    // 'class-methods-use-this': [
    //   'error',
    //   {
    //     exceptMethods: {},
    //     enforceForClassFields: true,
    //   },
    // ],
    complexity: 'off',
    // 'consistent-return': 'off',
    // 'consistent-this': ['error', 'that'],
    curly: 'off',
    // 'default-case': 'off',
    'default-case-last': 'error',
    'default-param-last': 'error',
    'dot-notation': 'off',
    eqeqeq: ['off', 'always'],
    // 'func-name-matching': 'off',
    'func-names': [0],
    // 'func-style': [0],
    'grouped-accessor-pairs': ['error', 'getBeforeSet'],
    'guard-for-in': [0],
    'id-denylist': [
      'error',
      'any',
      'Number',
      // 'number',
      'String',
      // 'string',
      'Boolean',
      // 'boolean',
      'Undefined',
    ],
    // 'id-length': '',
    'id-match': 'error',
    // 'init-declarations': 'off',
    // 'logical-assignment-operators': ['error', 'always', { enforceForIfStatements: true }],
    'max-classes-per-file': 'off',
    // 'max-depth': 'off',
    // 'max-lines': 'off',
    // 'max-lines-per-function': 'off',
    // 'max-nested-callbacks': 'off',
    // 'max-params': 'off',
    // 'max-statements': 'off',
    // 'multiline-comment-style': 'off',
    // 'new-cap': 'off',
    // 'no-alert': 'off',
    // 'no-array-constructor': 'off',
    'no-bitwise': 'off',
    'no-caller': 'error',
    'no-case-declarations': ['error'],
    // 'no-confusing-arrow': 'error',
    'no-console': 'off',
    // 'no-continue': 'error',
    'no-delete-var': ['error'],
    'no-div-regex': 'error',
    'no-else-return': ['error', {allowElseIf: true}],
    'no-empty': ['error', {allowEmptyCatch: true}],
    // 'no-empty-function': 'error', MAYBE: change
    // 'no-empty-static-block': 'error', MAYBE: change
    'no-eq-null': 'error',
    'no-eval': 'error',
    // 'no-extend-native': 'error',
    'no-extra-bind': 'error',
    'no-extra-boolean-cast': ['error', {enforceForLogicalOperands: true}],
    'no-extra-label': 'error',
    'no-extra-semi': 'error',
    // 'no-floating-decimal': '',
    'no-global-assign': ['error'],
    'no-implicit-coercion': [
      'error',
      {
        boolean: false,
        number: true,
        string: true,
        disallowTemplateShorthand: true,
        allow: ['~', '!!'],
      },
    ],
    // 'no-implicit-globals': '',
    // 'no-implied-eval': '',
    // 'no-inline-comments': '',
    'no-invalid-this': ['error', {capIsConstructor: true}],
    // 'no-iterator': '',
    'no-label-var': 'error',
    'no-label': ['off'],
    // 'no-lone-blocks': 'off',
    'no-lonely-if': 'error',
    'no-loop-func': 'error',
    'no-magic-numbers': 'off',
    'no-mixed-operators': [
      'error',
      {
        // groups: [
        //   ['+', '-', '*', '/', '%', '**'],
        //   ['&', '|', '^', '~', '<<', '>>', '>>>'],
        //   ['==', '!=', '===', '!==', '>', '>=', '<', '<='],
        //   ['&&', '||'],
        //   ['in', 'instanceof'],
        //   ['??'],
        //   ['?:'],
        // ],
        allowSamePrecedence: true,
      },
    ],
    'no-multi-assign': 'off',
    // 'no-multi-str': 'off',
    'no-negated-condition': 'error',
    'no-nested-ternary': 'off',
    // 'no-new': 'error',
    // 'no-new-func': 'error',
    'no-new-object': 'error',
    'no-new-wrappers': 'error',
    'no-nonoctal-decimal-escape': 'error',
    'no-octal': ['error'],
    'no-octal-escape': 'error',
    // 'no-param-reassign': 'off',
    'no-plusplus': 'off',
    // 'no-proto': 'off',
    'no-redeclare': 'error',
    'no-regex-spaces': ['error'],
    // 'no-restricted-exports': 'error',
    // 'no-restricted-globals': 'error',
    // 'no-restricted-imports': 'error',
    // 'no-restricted-properties': 'error',
    // 'no-restricted-syntax': 'error',
    // 'no-return-assign': 'error',
    'no-return-await': 'error',
    // 'no-script-url': 'error',
    'no-sequences': 'error',
    'no-shadow': ['off', {hoist: 'all'}],
    'no-shadow-restricted-names': ['error'],
    'no-ternary': 'off',
    'no-throw-literal': 'error',
    'no-undef-init': 'error',
    // 'no-undefined': 'error',
    'no-underscore-dangle': 'off',
    'no-unneeded-ternary': 'error',
    'no-unused-expressions': 'off',
    'no-unused-labels': 'error',
    // 'no-useless-call': ['error'],
    'no-useless-catch': ['error'],
    // 'no-useless-computed-key': 'error',
    'no-useless-concat': 'error',
    // 'no-useless-constructor': 'error',
    'no-useless-escape': ['error'],
    'no-useless-rename': ['error'],
    'no-useless-return': 'error',
    'no-var': 'error',
    'no-void': 'off',
    'no-warning-comments': 'off',
    'no-with': ['error'],
    'object-shorthand': 'error',
    'one-var': ['error', 'never'],
    // 'one-var-declaration-per-line': '',
    // 'operator-assignment': 'off',
    // 'prefer-arrow-callback': 'error',
    'prefer-const': ['error', {destructuring: 'all', ignoreReadBeforeAssign: false}],
    // 'prefer-destructuring': 'off',
    // 'prefer-exponentiation-operator': 'off',
    // 'prefer-named-capture-group': [0],
    // 'prefer-numeric-literals': [0],
    'prefer-object-has-own': 'error', // REQUIRES: es2022
    'prefer-object-spread': 'error',
    'prefer-promise-reject-errors': ['error', {allowEmptyReject: true}],
    'prefer-regex-literals': ['error', {disallowRedundantWrapping: true}],
    'prefer-rest-params': [0],
    'prefer-spread': [0],
    'prefer-template': 'error',
    'quote-props': ['error', 'as-needed'],
    radix: 'error',
    // 'require-await': 'error',
    // 'require-unicode-regexp': 'off',
    'require-yield': ['error'],
    'sort-imports': [
      'error',
      {
        ignoreCase: false,
        ignoreDeclarationSort: false,
        ignoreMemberSort: false,
        memberSyntaxSortOrder: ['none', 'all', 'multiple', 'single'],
        allowSeparatedGroups: true,
      },
    ],
    // 'sort-keys': 'off',
    // 'sort-vars': 'off',
    'spaced-comment': ['error', 'always', {markers: ['/']}],
    // 'strict': 'error',
    // 'symbol-description': '',
    // 'vars-on-top': '',
    // 'yoda': '',

    // ╭──────────────────────╮
    // │  Layout / Formatting │
    // ╰──────────────────────╯
    'array-bracket-newline': ['error', {multiline: true}],
    // 'array-bracket-spacing': ['error', 'always', { singleValue: false, arraysInArrays: false }],
    'array-element-newline': ['error', 'consistent', {multiline: true}],
    'arrow-parens': ['error', 'as-needed', {requireForBlockBody: true}],
    'arrow-spacing': ['error', {before: true, after: true}],
    'block-spacing': ['error', 'always'],
    'brace-style': ['error', '1tbs'],
    'comma-dangle': ['warn', 'always-multiline'],
    // 'comma-spacing': ['error', {before: false, after: true}],
    'comma-style': ['error', 'last'],
    'computed-property-spacing': ['error', 'never'],
    'dot-location': ['error', 'object'],
    'eol-last': 'off',
    'func-call-spacing': ['error', 'never'],
    'function-call-argument-newline': ['error', 'consistent'],
    // 'function-paren-newline': ['error', 'multiline'],
    'function-paren-newline': ['error', 'multiline-arguments'],
    'generator-star-spacing': ['error', 'before'],
    'implicit-arrow-linebreak': ['error', 'beside'],
    // indent: [
    //     'warn',
    //     4,
    //     {
    //         SwitchCase: 2,
    //         VariableDeclarator: {var: 2, let: 2, const: 3},
    //         outerIIFEBody: 1,
    //         MemberExpression: 1,
    //     }
    // ],
    // 'keyword-spacing': [],
    // 'line-comment-position': [],
    'linebreak-style': [1, 'unix'],
    // 'lines-around-comment': [],
    // 'lines-between-class-members': [],
    // 'max-statements-per-line': ['error', { 'max': 2 }],
    'multiline-ternary': ['error', 'always-multiline'],
    'new-parens': ['error', 'never'],
    'newline-per-chained-call': ['error', {ignoreChainWithDepth: 2}],
    'no-extra-parens': [
      'error',
      'all',
      {
        conditionalAssign: false,
        returnAssign: false,
        nestedBinaryExpressions: false,
        ignoreJSX: 'multi-line',
        enforceForNewInMemberExpressions: false,
        enforceForFunctionPrototypeMethods: false,
        enforceForSequenceExpressions: false,
        enforceForArrowConditionals: false,
      },
    ],
    'no-mixed-spaces-and-tabs': ['error'],
    // 'no-multi-spaces': ['error'],
    'no-multiple-empty-lines': ['error', {max: 2}],
    'no-tabs': 'error',
    'no-trailing-spaces': 'error',
    'no-whitespace-before-property': 'error',
    'nonblock-statement-body-position': ['error', 'below'],
    'object-curly-newline': ['error', {multiline: true}],
    'object-curly-spacing': ['warn', 'never'],
    // 'object-property-newline': ['error'],
    'operator-linebreak': ['error', 'after'],
    // 'padded-blocks': [],
    // 'padding-line-between-statements': [],
    // 'semi-spacing': [],
    'semi-style': ['error', 'last'],
    'space-before-blocks': ['error', 'always'],
    'space-before-function-paren': [
      'error',
      {anonymous: 'never', named: 'never', asyncArrow: 'always'},
    ],
    'space-in-parens': ['error', 'never'],
    'space-infix-ops': 'error',
    'space-unary-ops': ['error', {words: true, nonwords: false}],
    'switch-colon-spacing': ['error', {after: true, before: false}],
    'template-curly-spacing': ['error', 'never'],
    'template-tag-spacing': ['error', 'never'],
    // 'unicode-bom': 'never',
    'wrap-iife': ['error', 'inside', {functionPrototypeMethods: true}],
    'wrap-regex': 'error',
    'yield-star-spacing': ['error', 'after'],

    'import/extensions': 'off',
    'import/no-extraneous-dependencies': 'off',

    // ╭────────╮
    // │  React │
    // ╰────────╯
    'react/react-in-jsx-scope': 'off',

    // ╭───────────╮
    // │  Prettier │
    // ╰───────────╯
    // 'prettier/prettier': [
    //   'error',
    //   {
    //     useTabs: false,
    //     printWidth: 100,
    //     semi: false,
    //     singleQuote: true,
    //     quoteProps: 'as-needed',
    //     endOfLine: 'lf',
    //     trailingComma: 'all',
    //     parser: 'typescript',
    //     bracketSameLine: false,
    //     arrowParens: 'always',
    //     // arrowParens: 'avoid',
    //     jsxSingleQuote: false,
    //     bracketSpacing: true,
    //   },
    // ],

    // ╭────────╮
    // │  JSDoc │
    // ╰────────╯
    // https://www.npmjs.com/package/eslint-plugin-jsdoc
    // "jsdoc/check-access": "error",
    // "jsdoc/check-alignment": "error",
    // "jsdoc/check-indentation": "error",
    // "jsdoc/check-line-alignment": "error",
    // "jsdoc/check-param-names": "error",

    // 'jsdoc/check-examples': 'error',
    // 'jsdoc/newline-after-description': 'error',
  },
  overrides: [
    {
      files: ['*.js?(x)'],
      // extends: [],
    },
    {
      files: ['*.ts?(x)'],
      parser: '@typescript-eslint/parser',
      parserOptions: {
        ecmaVersion: 2022,
        project: './tsconfig.json',
      },
      extends: [
        'react-app',
        // 'plugin:@typescript-eslint/eslint-recommended',
        'plugin:@typescript-eslint/recommended',
        'plugin:react/recommended',
        'plugin:jsdoc/recommended',
        'eslint:recommended',
        // 'plugin:prettier/recommended',
        'prettier',
      ],
      plugins: ['jsdoc', '@typescript-eslint', 'prettier'],
      rules: {
        // ╭────────────────────╮
        // │  Typescript ESLint │
        // ╰────────────────────╯
        // https://typescript-eslint.io/rules/
        '@typescript-eslint/no-empty-function': 'off',
        '@typescript-eslint/no-explicit-any': 'off',
        '@typescript-eslint/no-inferrable-types': 'warn',
        '@typescript-eslint/no-namespace': 'off',
        '@typescript-eslint/no-non-null-assertion': 'off',

        '@typescript-eslint/ban-ts-comment': 'off',
        '@typescript-eslint/ban-types': 'off',
        '@typescript-eslint/prefer-namespace-keyword': 'warn',
        '@typescript-eslint/quotes': 'off',
        '@typescript-eslint/explicit-module-boundary-types': 'off',
        '@typescript-eslint/explicit-member-accessibility': ['error', {accessibility: 'no-public'}],
        //    "@typescript-eslint/explicit-member-accessibility": [
        //      "error",
        //      {
        //        "accessibility": "explicit",
        //        "overrides": {
        //          "accessors": "explicit",
        //          "constructors": "off"
        //        }
        //      }
        //    ],
        '@typescript-eslint/explicit-function-return-type': [
          'warn',
          {allowExpressions: true, allowTypedFunctionExpressions: true},
        ],
        '@typescript-eslint/no-unused-vars': [
          'warn',
          {
            argsIgnorePattern: '^_',
            varsIgnorePattern: '^_',
            caughtErrorsIgnorePattern: '^_',
          },
        ],
        //    "@typescript-eslint/no-unnecessary-boolean-literal-compare": "off",
        //    "@typescript-eslint/no-unnecessary-type-assertion": "off",
        //    "@typescript-eslint/prefer-string-starts-ends-with": "off",
        //    "@typescript-eslint/prefer-regexp-exec": "off",
        //    "@typescript-eslint/adjacent-overload-signatures": "error",
        //    "@typescript-eslint/array-type": "off",
        //    "@typescript-eslint/require-await": "off",
        //    "@typescript-eslint/await-thenable": "error",
        //    "@typescript-eslint/ban-types": "off",
        //    "@typescript-eslint/no-unsafe-assignment": "off",
        //    "@typescript-eslint/no-unsafe-member-access": "off",
        //    "@typescript-eslint/no-unsafe-call": "off",
        //    "@typescript-eslint/no-unsafe-return": "off",
        //    "@typescript-eslint/restrict-plus-operands": "off",
        //    "@typescript-eslint/restrict-template-expressions": "off",
        //    "@typescript-eslint/consistent-type-assertions": "error",
        //    "@typescript-eslint/consistent-type-definitions": "error",
        //    "@typescript-eslint/interface-name-prefix": "off",
        //    "@typescript-eslint/member-delimiter-style": "off",
        //    "@typescript-eslint/camelcase": "off",
        //    "@typescript-eslint/member-ordering": "off",
        //    "@typescript-eslint/no-empty-interface": "off",
        //    "@typescript-eslint/no-floating-promises": "error",
        //    "@typescript-eslint/no-misused-promises": "off",
        //    "@typescript-eslint/no-for-in-array": "error",
        //    "@typescript-eslint/no-misused-new": "error",
        //    "@typescript-eslint/no-parameter-properties": "off",
        //    "@typescript-eslint/no-unused-vars": "off",
        //    "@typescript-eslint/no-unnecessary-qualifier": "error",
        //    "@typescript-eslint/no-use-before-define": "off",
        //    "@typescript-eslint/no-unsafe-argument": "off",
        //    "@typescript-eslint/explicit-function-return-type": "off",
        //    "@typescript-eslint/no-var-requires": "off",
        //    "@typescript-eslint/prefer-for-of": "off",
        //    "@typescript-eslint/prefer-function-type": "off",
        //    "@typescript-eslint/quotes": "off",
        //    "@typescript-eslint/semi": ["error", "never"],
        //    "@typescript-eslint/triple-slash-reference": [
        //      "error",
        //      {
        //        "path": "always",
        //        "types": "prefer-import",
        //        "lib": "always"
        //      }
        //    ],
        //    "@typescript-eslint/unbound-method": "off",
        //    "@typescript-eslint/unified-signatures": "error",
      },
    },
    {
      files: ['*.test.ts?(x)'],
      // extends: ['plugin:jest/recommended'],
      env: {jest: true},
    },
  ],
};
