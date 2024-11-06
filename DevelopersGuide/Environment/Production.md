# Production Instance

Production is the last stage in the application lifecycle. It's the [Instance](Instance.md) which is used by end users. It represents the final product, where things must run smoothly and the system must be high performant, secure, robust, responsive and easy to use.

Unexpected behavior in this instance could have a damaging consequences so it's essential that we take this Instances seriously and all management activities are planned and with low risk.

Production Instance uses the same [Image](../Deployment/Images.md) as [Staging](Staging.md) Instance so we can be sure that the [Digital Content](DigitalContent.md) works as expected because all tests should pass in the Staging Instance before a deployment is made to the Production Instance.

Production Instances are typically compiled in **Release** optimization mode which means the source code is optimized for fast execution but it lacks debugging support. We should never debug Production Instance, there's always a cause in a source code for unexpected environment, never in the Instance itself so we should structure code that way the we can easily locate bugs and fix them. 