task("tokenSetTrustedRemote",
    "Set up the trusted remote addresses for tokens.",
    require("./tokenSetTrustedRemote")
).addParam(
    "targetNetwork",
    "the targetNetwork to set as trusted"
)