# Contributing

Contributions are more than welcome. Bug reports with specific reproduction steps are great. If you have a code contribution you'd like to make, open a pull request with suggested code.

Note that PR's and issues are reviewed every ~2 weeks. If your PR or issue is critical in nature, please reflect that in the description so that it receives faster attention.

Pull requests should:

* Clearly state their intent in the title
* Have a description that explains the need for the changes
* Include tests! (Make sure the scripts complete in your test environment)
* Not break the public API
* Add yourself to the CONTRIBUTING file

By contributing to this project you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose

Copyright (c) 2017 New Relic, Inc. All rights reserved.

## Testing

[Molecule](https://molecule.readthedocs.io/) can be used run integration tests
on the module. The default driver uses [Docker](https://www.docker.com/community-edition)

To install and run Molecule run:

```bash
virtualenv --no-site-packages .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Once Molecule is installed, use `molecule test` to run the tests.

## Contributors

* [Abed Kassis](https://github.com/abedk)
* [Alexander Merkulov](https://github.com/merqlove)
* [Brent Walker](https://github.com/tacchino)
* [danvaida](https://github.com/danvaida)
* [Koen Punt](https://github.com/koenpunt)
* [Nathan Smith](https://github.com/smith)
* [Rutger de Knijf](https://github.com/rdeknijf)
* [Ryan Pineo](https://github.com/ryanpineo)
* [Ruben Hervas](https://github.com/xino12)
* [Johannes Hartmann](https://github.com/jojo221119)
* [Alejandro Do Nascimento](https://github.com/alejandrodnm)
