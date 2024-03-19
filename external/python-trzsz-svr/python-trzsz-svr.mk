################################################################################
#
# python-trzsz-svr
#
################################################################################

PYTHON_TRZSZ_SVR_VERSION = 1.1.4
PYTHON_TRZSZ_SVR_SOURCE = trzsz-svr-$(PYTHON_TRZSZ_SVR_VERSION).tar.gz
PYTHON_TRZSZ_SVR_SITE = https://files.pythonhosted.org/packages/22/a0/e9a530592ecc36d0ccc2dae6cabb45540d3b6da5bf5fb2d6dc79ae999544
PYTHON_TRZSZ_SVR_LICENSE = MIT
PYTHON_TRZSZ_SVR_LICENSE_FILES = LICENSE.md
PYTHON_TRZSZ_SVR_CPE_ID_VENDOR = python
PYTHON_TRZSZ_SVR_CPE_ID_PRODUCT = trzsz-svr
PYTHON_TRZSZ_SVR_SETUP_TYPE = setuptools

$(eval $(python-package))
$(eval $(host-python-package))
