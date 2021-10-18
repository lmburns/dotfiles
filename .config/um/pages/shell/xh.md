# xh --
{:data-section="shell"}
{:data-date="May 23, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Send http requests

## OPTIONS

`=/:=`
: for setting the request body's JSON or form fields (= for strings and := for other JSON types).

`==`
: for adding query strings.

`@`
: for including files in multipart requests e.g picture@hello.jpg or picture@hello.jpg;type=image/jpeg.

`:`
: for adding or removing headers e.g connection:keep-alive or connection:.

`;`
: for including headers with empty values e.g header-without-value;.

 `=@/:=@`
 : for setting the request body's JSON or form fields from a file (= for strings and := for other JSON types).

`xh httpbin.org/json`
: Send a GET request

`xh httpbin.org/post name=ahmed age:=24`
: Send a POST request with body {"name": "ahmed", "age": 24}

`xh get httpbin.org/json id==5 sort==true`
: Send a GET request with querystring id=5&sort=true

`xh get httpbin.org/json x-api-key:12345`
: Send a GET request and include a header named x-api-key with value 12345

`xh put httpbin.org/put id:=49 age:=25 | less`
: Send a PUT request and pipe the result to less

`xh -d httpbin.org/json -o res.json`
: Download and save to res.json

`https://httpie.io/docs#request-items`
: url for help
