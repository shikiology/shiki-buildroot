################################################################################
#
# python-trzsz-libs
#
################################################################################

PYTHON_TRZSZ_LIBS_VERSION = 1.1.4
PYTHON_TRZSZ_LIBS_SOURCE = trzsz-libs-$(PYTHON_TRZSZ_LIBS_VERSION).tar.gz
PYTHON_TRZSZ_LIBS_SITE = https://files.pythonhosted.org/packages/ae/81/c1e3cc75c7bfa69bf5f190a8399be84fb59b871e182b0b90b2f8448b733d
PYTHON_TRZSZ_LIBS_LICENSE = MIT
PYTHON_TRZSZ_LIBS_CPE_ID_VENDOR = python
PYTHON_TRZSZ_LIBS_CPE_ID_PRODUCT = trzsz-libs
PYTHON_TRZSZ_LIBS_SETUP_TYPE = setuptools

$(eval $(python-package))
$(eval $(host-python-package))
