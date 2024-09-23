locals {
  name_regex = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters  name: \/"'[]:|<>+=;,?*@&
  env_4                         = substr(var.env, 0, 4)
  serverType_3                  = substr(var.serverType, 0, 3)
  userDefinedString_7           = substr(var.userDefinedString, 0, 7)
  as-name                       = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_7}-as", local.name_regex, "")
  lb-name                       = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_7}-lb", local.name_regex, "")   

}