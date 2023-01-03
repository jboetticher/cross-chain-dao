task("daoSetTrustedRemote",
    "Set up the trusted remote addresses for a DAO.",
    require("./tokenSetTrustedRemote")
).addParam(
    "targetNetwork",
    "the targetNetwork to set as trusted"
)

task("tokenSetTrustedRemote",
    "Set up the trusted remote addresses for tokens.",
    require("./tokenSetTrustedRemote")
).addParam(
    "targetNetwork",
    "the targetNetwork to set as trusted"
)

task("voteAggSetTrustedRemote",
    "Set up the trusted remote addresses for a VoteAggregator.",
    require("./voteAggSetTrustedRemote")
)

task("readTokenData", 
    "Reads data about the CrossChainDAOToken.",
    require("./readTokenData")
);