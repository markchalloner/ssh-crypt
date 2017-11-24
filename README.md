# SSH Crypt

ssh-crypt allows encryption of plain-text using an SSH public key.

## Usage

```
ssh-crypt [options]

Options

    -h, --help                      optional: Show this message.
    -n, --name <name>               optional: Unique identifier of user (e.g. firstname.lastname or example@domain.tld)
                            used to cache the user's public key. If not specified then ssh-crypt will fallback
                            to asking for it on run.
    -i, --input-file <file>         optional: Path to plain-text file to encrypt. If not specified then ssh-crypt will use
                            plain-text from stdin or fallback to asking for it when run.
    -o, --output-file <file>        optional: Path to encrypted file. If not specified then ssh-crypt will output the
                            encrypted text to stdout (and copy it to the clipboard if possible)
    -p, --public-key-file <file>    optional: Path to public key file. If not specified then ssh-crypt will check the
                            cache for a file matching the `name` argument.

Cache

Public keys are cached in ~/.ssh-crypt.
```

## Install/Uninstall
Use the included make file to install or uninstall

Install:

```bash
git clone https://github.com/markchalloner/ssh-crypt.git
cd ssh-crypt
sudo make install
```

Uninstall:

```bash
git clone https://github.com/markchalloner/ssh-crypt.git
cd ssh-crypt
sudo make uninstall
```

## Examples

Using interactively:

```bash
$ ssh-crypt
Enter the user's name: example@domain.tld
Cached public key found. Would you like to use this (Y/n): n
Enter the public key (followed by an empty line):
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/pyZFLExrP+vtGZ5FflHVDKsjzDXaFRqk/gsiF4RJUAOF18v5dSxwIyHx45jpMyfyhTg8FIaxgdpqK3F8ERALfU6Txp4mUEkaI0y04MhSPFwsw2Q45bGIrgpb9f/5L23/DcEue7Y8UkhtG/gAu2EWNyvfAml7ed6Te6/u4aPLCZPix1v4WqvVvVkS9SFJqvJYZqQ+ZnumQbEwA5PEBI7FKmzcqgahafcgSr4I418BjCcF6ZstHKoO+ZQ1bVjA5tPcNIu4jmJ9tSAdaujzPLEwxYA8P9HsxjuV8fXlLcYYMRwgab7lnwt8qEEZOYWO8bWiGHOKTBHYKsFTqiY+WDq9eJb2SsArNjHzbMmuzceg8eDMaFwTKeTGu9K98yAwHNNIkU3T3rUG5Abc99zi6OU2v/n804Z7VBOIl+hsGER2cilN4d9rDzmsO04E/Jw7BIGYfcH7NX92nSW+ZUUjRX8e/Pl2fToO0edntHkoCJzbCkgx1FXZy1XCGRKo+Z1cx5J3z7plAh4L2YQgzKQ/bhI9d/TyqPqh/wl4lkywQZjwq3OaCZ9ufxZ78MSoCtohF21Wa86OtqIYjG8T0z7eZEra7HSPKk+gFzIg/nmfoLkNwlllg4w5qXF2oUvsB59RvpjGmnKvIMK3G7VOv3havKHv/LCNTrm5Mr1T3a/MIrjyYw== example@domain.tld

Enter the text to encrypt (followed by an empty line):
foobar

pBURlPWmROiesciSkV3pDfLEhMZgF2oWSbCGnj/VciRMwJME5e7nIuXnMTcEsQ+VWuttQIYVbgp7p1C6KxhWgvVm8VgaiXqcUQhkKkZNFamRZcZdW928GHfQ++vO9eoOy9u3ZFfULm8HHK9LePAtEi1knhYHy2MHcw/QOTnYXtTgPEY1QjpXIwpBb/zQBz7XSW/2HVBHcklQQ83qcfoGYK0UNM5rMs2G8xXsK/K37h0QfPTOzvgJ1fvGXrV75y6iZDXUJZgsALPRmeG3mYLSjs/au9ppWNu5oG2sXoOHtMtxXK98r/G4yrkQGr6fKTRLAGjepWTfkaqqn1VDCTb3iiiGBoNik4rGD0uoX8JgI+rlTIdoPW9Xa73rQCV9EV0LH6ufiUenCMOBYqyVDcHa/uetbbUMRRGkBb5gU2Ogeec2ALVDcKcayLgcxYifE0BYs1jOSdLOVSxwNE9usDgrhTgoEtX7t6k/CMxILWXs0sOVG4QmwOBdSmSaEqz2LhasATOqgF7UkFh9lNf7Dbks8bkYYe2i+tEWlLCSYA93nNwP09cBLW/jAf+lCJD7EFR6Man7w7KO3ZnE30KWgTMZF+DgwwJ+OmgebHSXQS6X6be5Z9iHdVp1ZZ3Ola+mGyIqJghF0QhE1/wvh27+zGGcqjOHj1iXetIGKaju8/S5Oig=
Decrypt with: { base64 -D | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa ; } <<< ${encrypted_text}
```

Using command line arguments:

```bash
$ ssh-crypt -n example@domain.tld -p ~/.ssh-crypt/example@domain.tld.pem -i plaintext.txt -o secret.enc
Encrypted text saved to: secret.enc
Decrypt with: base64 -D -i secret.enc | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa
```

Using stdin and stdout:

```bash
$ ssh-crypt -n example@domain.tld -p ~/.ssh-crypt/example@domain.tld.pem <<< "foobar" > secret.enc
Decrypt with: { base64 -D | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa ; } <<< ${encrypted_text}
$ cat secret.enc
BdRa+z5JfxWvIXdrOugAE1U+VU4YYJEPpM3OgylNgmwhM7HjZPQpFPYmk5GPVE+/Nc5mJM0O5yX88JdvDAkYas72FFuDC/JLDQHZIN/ymaJ50UEzTwKYnffT0maxH4pE963i1P1BHnShyl6ZcOqEmQrWNmHtTr/IkOsB3CCMPqtfTPI1cRiKbtPUsny/5jD3Outx/CuVvYo1mG5KyyHjRlp63W6lWsYCR97YMpKOiVm8DlmZLwjzP/Uf4kfsaKo5fs1Q51vOowUJAu8El09vnLCusgcIwI0401oa1TdpA3ARTAWJ2Nw2Imi39Ks4zcGzoXqLQesjGLCEqUp7CeZCn+0QgOUFeCmemtqEn137XMAvyZrUBI2KWZUBfWkH9GbVzGy05J2MD8x/l4S3Oq3TCph3VWiA88RYzsUMXCr4XxkSqGXfVtDOYLmLYXbXSsYu/eCXDjnEgwPXo4rp/Iriw9w/afKMCf68S+7aF/2E+WsICCuhBDgqCtUW9BWVV0/7qyJbIXHU+mRLZ6Aye2YmfvDT2FmNyhJRkcobxnAT1C1tm4qKcC2pdDH3CBQg+qH3PMmNjAEjf+NQXnpNCGtCdUfQaxMq+3i/Es9Bs0yl2wk1r1sVKmx1BcSLVtGk5FFWRLj1/eRjkLzsEnK7CFsuDeOCD4vxnm6Q/ZylxgDY3e8=
```

## Readme
Generated with:

```bash
ssh-crypt -r
```
