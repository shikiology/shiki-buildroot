################################################################################
#
# python-trzsz
#
################################################################################

PYTHON_TRZSZ_VERSION = 1.1.4
PYTHON_TRZSZ_SOURCE = trzsz-$(PYTHON_TRZSZ_VERSION).tar.gz
PYTHON_TRZSZ_SITE = https://files.pythonhosted.org/packages/02/bf/1ee2d66a0ae97eb7fa893239a512a8a19058e325323828a591232f9dd8aa
PYTHON_TRZSZ_LICENSE = MIT
PYTHON_TRZSZ_LICENSE_FILES = LICENSE.md
PYTHON_TRZSZ_CPE_ID_VENDOR = python
PYTHON_TRZSZ_CPE_ID_PRODUCT = trzsz
PYTHON_TRZSZ_SETUP_TYPE = setuptools

$(eval $(python-package))
$(eval $(host-python-package))
