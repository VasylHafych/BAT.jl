
"""
    PartitionedSampling

The algorithm that partitions parameter space by multiple subspaces and
samples/integrates them independently (See arXiv reference).

The default constructor is using `MetropolisHastings` sampler,
`AHMIntegration` integrator, and `KDTreePartitioning`:

    PartitionedSampling()

"""
@with_kw struct PartitionedSampling{S<:AbstractSamplingAlgorithm,
    I<:IntegrationAlgorithm, P<:SpacePartitioningAlgorithm} <: AbstractSamplingAlgorithm
    exploration_algm::S = MetropolisHastings()
    partiton_algm::P = KDTreePartitioning()
    sampling_algm::S = MetropolisHastings()
    integration_algm::I = AHMIntegration()
end

export PartitionedSampling


"""
    function bat_sample(
        posterior::PosteriorDensity,
        n::Tuple{Integer,Integer, Integer},
        algorithm::PartitionedSampling;
        n_subspaces::Integer,
        sampling_kwargs::NamedTuple,
    )

Sample partitioned `posterior` using sampler, integrator, and space
partitioning algorithm specified in `algorithm` with corresponding kwargs
given by `exploration_kwargs`, and `sampling_kwargs`.
3
`n` must be a tuple `(nsteps, nchains, npartitions)`. `posterior` must be a uniform
distribution for each dimension.
"""
function bat_sample(
    posterior::PosteriorDensity,
    n::Tuple{Integer,Integer, Integer},
    algorithm::PartitionedSampling;
    exploration_kwargs::NamedTuple = NamedTuple(),
    sampling_kwargs::NamedTuple = NamedTuple(),
    n_exploration::Tuple{Integer,Integer} = (10^2, 40)
)
    n_samples, n_chains, n_subspaces = n

    @info "Generating Exploration Samples"
    exploration_samples = bat_sample(posterior, n_exploration, algorithm.exploration_algm; exploration_kwargs...).result

    @info "Construct Partition Tree"
    partition_tree, cost_values = partition_space(exploration_samples, n_subspaces, algorithm.partiton_algm)

    @info "Sample Parallel"

    samples_subspace = sample_subspace(
        posterior, (n_samples, n_chains), algorithm.sampling_algm,
        algorithm.integration_algm, 1, sampling_kwargs)

    @info "Combine Samples"

    # return (result = (...), info = (integral, uncert, cpu_time, wc_time, worker_id, sample_ind, param_bounds), part_tree = tree)
    return (exp_samples = exploration_samples, part_tree = partition_tree, cost_values = cost_values)
end

function sample_subspace(
    posterior::PosteriorDensity,
    n::Tuple{Integer,Integer},
    sampling_algorithm::A,
    integration_algorithm::I,
    space_id::Integer,
    sampling_kwargs::N
) where {N<:NamedTuple, A<:AbstractSamplingAlgorithm, I<:IntegrationAlgorithm}

    samples_subspace = bat_sample(posterior, n, sampling_algorithm; sampling_kwargs...).result

    integras_subspace = bat_integrate(samples_subspace, integration_algorithm).result

    return samples_subspace
end
