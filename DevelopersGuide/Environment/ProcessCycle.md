# Implementation Process Cycle

Digital transformation is an endless, iterative process with the goal to provide improvement with each cycle. Each cycle brings a complete, working unit that brings an added value to the business environment.

There can be many active parallel cycles at the same time, but each of them is treated as a separate mini project with its very own schedule, requirements and deployment.

*Connected* has a precisely defined implementation process, which carries project teams from point zero to point one.

Each development cycle consists of the following stages:

- Analysis
- Model
- Design
- Test
- User Acceptance Test
- Production

As you can see, there are several stages in the process until the new feature reaches the *Production* stage. Some stages can overlap and they can repeated multiple times before they eventually complete.

## Analysis

This is the very first stage of each digital transformation cycle. It typically includes both parties, the vendor and customer. In this stage the requirements are identified and then the experts analyze the business problem and their target is to find out how the digital transformation will bring added value and how much effort should be put in the end product.

Having those information the sponsor can easily decide if the new feature has a positive **Return of Investment*** (ROI) which determines wether to continue with the next stage of put the feature back to the **back log** and maybe analyze it in the future again.

Once the business point of view is accepted, the *Digital Transformation Expert* creates tasks for all stages and enters estimations for each task.

In this stage the following experts can be involved:

- Digital Transformation Architect
- Digital Transformation Expert
- Domain Expert

## Model

*Analyze* stage must be fully completed before the *Model* stage begins. In this stage all [Model Microservices](../Microservices/Model.md) are created and the modelling process begins. All [Entities](../ServiceLayer/Entities/README.md) and [Services](../ServiceLayer/README.md) are created and in the end of this stage we have a complete overview how the end product will looks like from the architecture point of view.

Any errors in design are detected in this stage because we don't really have to write implementation code to find out that properties are missing on an [Entity](../ServiceLayer/Entities/README.md) or that a [Service](../ServiceLayer/Services/README.md) does not provide a [Service Operation](../ServiceLayer/Services/Operations.md) we need.

In this stage we find out which references we need to the existing [Microservices](../Microservices/README.md). 

The **User Interface Experience** (UX) also take place in this stage since we must have as user interfaces designed and confirmed by the key users before we start with their implementation. The UX can be designed directly in the *Connected* with mock data.

*Digital Transformation Expert* will write **User Acceptance Tests** in this stage and they must be confirmed by customer before this stage completes since this is the essential criteria for a new feature to reach the production stage.

Experienced team will fully complete this stage before moving to the next stage. 

In this stage the following experts can be involved:

- Digital Transformation Architect
- Digital Transformation Expert
- Domain Expert
- User Experience Expert

It's not necessary that all of them are involved in every cycle but on the average they will regularly appear.

This stage is performed on the local [Development](Development.md) instance.

## Design

Design stage means implementing models. A numerous of [Microservices](../Microservices/README.md) are created, typically one for each [Service](../ServiceLayer/Services/README.md) in the [Service Layer](../ServiceLayer/README.md) and one for each [Service](../ServiceLayer/Services/README.md) in the [User Layer](../UserLayer/README.md).

Developers also write Unit Tests in the stage. This stage won't be fully completed before the *Test* stage is performed. They interchangeably occur as frequently as possible with the goal to complete the development stage as soon as possible.

In this stage the following set of experts are involved:

- Senior Developer
- User Interface Specialist

This stage is performed on the local [Development](Development.md) instance.

## Test

Testing is performed on the implemented [Microservices](../Microservices/README.md), for the [Service Layer](../ServiceLayer/README.md) and [User Layer](../UserLayer/README.md). *Unit Tests* are performed for the [Service Layer](../ServiceLayer/README.md) and *User Interface Tests* are performed for the [User Layer](../UserLayer/README.md). If bugs or inconsistencies are found the stage returns to the *Design* and waits for the fix to be available and perform the Test again until the feature is considered fully implemented and working as expected.

If the feature needs to be documented the *Technical Writer* role is involved in this stage to write appropriate documentation. Also, if the feature will need either in person education or video tutorials to be recorded, *Training Specialist* is also involved in this stage.

In smaller teams *Quality Assurance Engineer*, *Technical Writer* and *Training Specialist* could be the same person, but in larger environments roles are typically assigned to different people.

In this stage the following set of experts are involved:

- Quality Assurance Specialist
- User Interface Specialist
- Technical Writer
- Training Specialist

This stage is performed on the local [Quality](Quality.md) instance.

## User Acceptance Test (UAT)

Once the *Test* stage completes, the focus is moved to the [Staging](Staging.md) [Instance](Instance.md). Both teams previously arrange a meeting on which they perform *User Acceptance Tests* to validate the new feature. This stage includes exactly the same set of [Microservices](../Microservices/README.md) that will be later present in the [Production](Production.md) since in this stage two more tests could be performed:

- End to End
- Integration

Which tests are performed depends on the scale of the feature. Small features might pass *UAT* without additional tests, but if the feature interferes with existing features it might be a necessary that all tests should be performed again.

In this stage the following experts are involved:

- Digital Transformation Expert
- Quality Assurance Specialist
- Technical Writer
- Training Specialist

This stage is performed on the cloud [Quality](Quality.md) instance.

The documentation is also delivered and if the feature requires so, the Training is performed before the feature enters the *Production* stage.

The customer might want to perform its own validation after the *UAT* successfully passes.

## Production

Once the *User Acceptance Test* successfully passes and Customer confirms that changes should go live The Production stage occurs which is the final stage of the new feature. This stage typically occurs automatically by [Deploying](../Deployment/README.md) changes to the [Production](Production.md) [Instance](Instance.md).

In this stage the following expert is involved:

- Customer Service or DevOps

This stage is performed on the [Production](Production.md) [Instance](Instance.md) being on a [Public Cloud](PublicCloud.md) or [Private Cloud](PrivateCloud.md).
