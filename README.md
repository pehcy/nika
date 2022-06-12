<h1 align="center">nika</h1>

<h3 align="center">Continuous benchmarking for performance regression</h3>

<img align="center" src="https://miro.medium.com/max/1200/1*AqDkZGzbxf_ygqCGm0MlEQ.jpeg" />

## Problem statement

We want to find out the performance of the program and integrate in the CI infrastructure. We have trying to find a way to visualise the performance of the program as precise as possible.

## Solution

We treat the performance of the program as a mean of execution time (aka wall time). To do this we first make a CLI tool to visualise the wall time in a bell curve by statistics. (** TODO: we will elaborate deeper into this **).

The program will need to concat the time into a csv file. And we will calculate the confidence interval. If it is exceeding the __predefined__ critical value, we will raise certain warnings for CI to react.

And because of running the program in a noisy environment (imagine non-dedicated CI server...), we will get a relatively big variance in the wall time data. We need to calculate the variance plus mean, and calculate the __confidence interval__.


## Mission and non mission

* This is not a microbenchmarking libraries, if you want this, you can find something like criterion on both rust and haskell.
* This is not a haskell libraries, it is language-agnostic tool
* This is going to be a fun project.

## TODO
* Graph drawing
* Profiling?
* SoMeThInG LiKe the rustc perf bot? (calculate the CPU instructions, cache misses)
* SoMeThIng lIkE the zig perf page? (visualisation instead of showing data)
