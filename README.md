# Seagrass

Seagrass is a small language that compiles to BEAM and treats sequencing and
parallelism as first-class syntax.

The language was created to make workflow-style programs easier to read and
harder to accidentally serialize. In Seagrass, a newline means "do this after
the previous step", while a comma means "run these branches in parallel". That
gives the source code a shape that matches the execution model.

## Why it exists

Seagrass was designed around a simple idea: business and automation flows are
usually described as ordered steps with occasional forks and joins, but general
purpose languages tend to hide that structure inside libraries, callbacks, job
queues, or ad-hoc process orchestration.

It also comes from a more specific lineage: Seagrass is intended as a logical
evolution of BPML ideas, but with a syntax that behaves like a real programming
language instead of an XML workflow notation. The goal is to keep the process
model visible while making it compact, composable, and executable on BEAM.

That matters especially for complex processes that require explicit logical
gateways. Real workflows often split into parallel branches, let those branches
run independently, and then wait for them to complete before continuing. In
Seagrass, those joins are not hidden in an engine-specific diagram node: they
are expressed directly in the program structure through parallel branches and
their enclosing sequential flow.

Seagrass makes that structure explicit:

- sequential steps are written on separate lines
- parallel branches are written on the same level with `,`
- grouped branches are written with `{ ... }`
- gateways and joins are expressed by the structure of nested sequential and parallel blocks
- the result still compiles to regular Erlang/BEAM artifacts

The goal is not to replace Erlang or Elixir. The goal is to offer a smaller
language whose syntax is optimized for orchestration, parallel branching, and
clear execution flow.

## Example

```seagrass
import io

io.print("start")

io.print("left"), {
    io.print("right-1")
    io.print("right-2")
}

io.print("end")
```

In that program, `io.print("left")` runs in parallel with the block on the
right. Inside the block, `right-1` and `right-2` run sequentially.

## Example Collection

Seagrass is most useful when the problem already looks like a workflow. The
repository includes a growing set of examples that model the kinds of flows
you would normally describe in BPM tools, CI/CD systems, or orchestrators such
as Airflow.

Business logic:

- [Hello World](examples/hello-world/hello-world.sg)
- [Basic Workflow](examples/basic-workflow/basic-workflow.sg)
- [Order Fulfillment](examples/business-order-fulfillment/order-fulfillment.sg)
- [Loan Underwriting](examples/business-loan-underwriting/loan-underwriting.sg)

CI/CD:

- [Monorepo Release Pipeline](examples/cicd-monorepo-release/monorepo-release.sg)
- [Blue-Green Deployment](examples/cicd-blue-green-deploy/blue-green-deploy.sg)

Data pipelines:

- [Daily ETL Pipeline](examples/data-daily-etl/daily-etl.sg)
- [Feature Engineering Pipeline](examples/data-feature-pipeline/feature-pipeline.sg)

Full index:

- [examples/README.md](examples/README.md)

## Comment syntax

Seagrass supports three comment styles:

```seagrass
// line comment
# line comment
/* block comment */
```

Block comments may span multiple lines.

## Toolchain

```bash
make dev-ubuntu   # bootstrap a Ubuntu development environment
make build        # compile the project
make install      # install sg in ~/.local/bin
```

## Current direction

The current implementation focuses on:

- module imports
- sequential execution
- parallel branching
- grouped nested branches
- code generation to Erlang

More language features described under `docs/` are planned, but not all are
implemented yet.
