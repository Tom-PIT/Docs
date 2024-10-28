# Compilation

*Connected* compiles [Microservice](../Microservices/README.md) source code on [start-up](Startup.md). The platform is smart enough to know which [Microservices](../Microservices/README.md) should recompile in order to optimize [start-up](Startup.md) performance.

Once the [Microservice](../Microservices/README.md) is compiled it remains intact until the changes are made to its source code. Namely, *Connected* deploys source files instead of precompiled binaries. There are several reasons for that. First, *Connected* has in [Ide](../IDE/README.md) integrated directly into platform so the source files must be always available. Second, not all files are compilation files. Script files or templates does not compile and their source must be present as a non binary anyway. Third, legacy components used ```C#``` scripting files (```.csx```) which are linked and compiled on the fly and thus must be present locally.

Compiling on the target system has several advantages. First, the compiled code is optimized for the environment where it runs. Second, only changed source files are transferred not the entire binary set. Binaries can be quite large files and deploying them over and over again causes a big overhead while *Connected* uses smart deployment delta algorithms to send only those files to the target environment that have been changed.

## Compilation Process

Compilation occurs early in the start-up process. Once the [Shell](Shell.md) infrastructure services are initialized, *Connected* queries all [Microservices](../Microservices/README.md) from the configuration. It generates a dependency graph and then it starts checking which [Microservice](../Microservices/README.md) should be recompiled. [Shell](Shell.md) infrastructure keeps records of all changes made to the source file and this way it can determine if [Microservice](../Microservices/README.md) has changed.

If a [Microservice](../Microservices/README.md) has recompiled, all [Microservices](../Microservices/README.md) that depends on it are recompiled as well regardless if they've been changed or not.

*Connected* compiles [Microservices](../Microservices/README.md) one after another, it does not do it in parallel. If one compilation fails, the system fails to start. All compilation errors must be fixed for [Instance](Instance.md) to start successfully.

## Recompiled Flag

*Connected* carries the recompiled information into the [Startup](../Microservices/Startup.md) so you can always know wether the specific [Microservice](../Microservices/README.md) has recompiled or not. It's important information because some [Microservices](../Microservices/README.md) need to perform some tasks when recompiled.