task("daoSetTrustedRemote",
    "Set up the trusted remote addresses for a DAO.",
    require("./tokenSetTrustedRemote")
).addParam(
    "targetNetwork",
    "the targetNetwork to set as trusted"
);

task("tokenSetTrustedRemote",
    "Set up the trusted remote addresses for tokens.",
    require("./tokenSetTrustedRemote")
).addParam(
    "targetNetwork",
    "the targetNetwork to set as trusted"
);

task("voteAggSetTrustedRemote",
    "Set up the trusted remote addresses for a VoteAggregator.",
    require("./voteAggSetTrustedRemote")
);

task("readTokenData", 
    "Reads data about the CrossChainDAOToken.",
    require("./readTokenData")
).addParam(
    "acc",
    "the account to read"
);

task("readDAOData", 
    "Reads data about the CrossChainDAO.",
    require("./readDAOData")
).addParam(
    "acc",
    "the account to read"
);

task("readProposalData", 
    "Reads data about a proposal.",
    require("./readDAOData")
).addParam(
    "proposalid",
    "the proposalid to read"
);

task("delegateVotes",
    "Delegates token votes to an account.",
    require("./delegateVotes")
).addParam(
    "acc",
    "the account to delegate votes to"
);

task("newEmptyProposal",
    "Creates a new proposal on the hub chain.",
    require("./newEmptyProposal")
).addParam(
    "desc",
    "the description of the empty proposal"
);

task("vote",
    "Votes on a proposal.",
    require("./vote")
).addParam(
    "proposalid",
    "the id of the empty proposal"
).addParam(
    "support",
    "0 for con, 1 for pro"
)