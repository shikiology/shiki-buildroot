################################################################################
#
# r8125
#
################################################################################

R8125_VERSION = 9.012.04
R8125_SITE = $(BR2_EXTERNAL_SHIKI_PATH)/r8125
R8125_SITE_METHOD = local

$(eval $(kernel-module))
$(eval $(generic-package))
