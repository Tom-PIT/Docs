# Collections

*Connected* offers a wide range of tools and services that enable data processing. The idea behind processing data is to have high level components that enable distributed, parallel and asynchronous processing. 

Collections represent data sets which can contain many records, often several million or more. Those collections have to be processed as efficient as possible so data can be ready for clients with small latency.

*Connected* encourages developers to precalculate data with the goal to achieve high read performance in exchange to a more complex writes. Reading a calculated total of issued invoices for the current month is much faster if we aggregate invoices by days, months, maybe even weeks and quarters. This way, we can read a single record which is much faster that reading all invoices from the invoice record set and calculate the total on the fly because there can be thousands of invoices each month and by performing the same calculation over and over again seems impractical.

Aggregations are great from the performance point of view but are much harder to achieve. First, we need an infrastructure that provides the necessary services for achieving the goal. There are several conditions that have to be met.

## Background Processing

The first condition is to move data processing in the background, isolated from the user experience with no impact on overall performance.

## Parallel Processing

Background processing is great, but it must somehow provide mechanism that one expensive processing does not cause other tasks to stall. Instead, the infrastructure must provide the ability to process tasks in parallel, independently of each other. Yet, providing the ability to control which tasks and when are ready for processing is an essential feature.

## Asynchronous Processing

Users do not like to wait, they expect a performant system without latencies, being responsive and reactive. The processing must be asynchronous which means users can continue to work while the processing is performed without impacting their experience.

## User Experience

Nowadays users are really demanding and rightly so. The technology is advancing on a daily basis and expecting a fluid and responsive user experience is today a minimum.

Processing data in background, spanning across several threads, sometimes even processes can cause great challenges to eventually provide a consistent and optimal user experience.

## Scalable

[Instances](../../Environment/Instance.md) have limitations. We can do a scale up, sometimes called vertical scaling, until the upper limit is reached. Then, scale out, sometimes called horizontal scaling is the only option, so the infrastructure must provide tools to scale processing across several processes without impacting user experience.

## Services

*Connected* provides two services which solve the challenges stated above:

- [Queues](Queues.md)
- [Workers](../../ServiceLayer/Workers/README.md)

Each of the services serve better for their purpose but you will definitely find them indispensable when implementing digital content. 