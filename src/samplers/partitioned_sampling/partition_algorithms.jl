# This file is a part of BAT.jl, licensed under the MIT License (MIT).

abstract type SpacePartitioningAlgorithm end
export SpacePartitioningAlgorithm

"""
	KDTreePartitioning

*BAT-internal, not part of stable public API.*

K-D binary space partitioning algorithm. By default, all parameters are
considered for partitioning. Partition parameters can be specified
manually by using `partition_dims` argument. By default, bounds of the
partitioning tree are extended to those given by prior. This can be changed
by setting `extend_bounds = false`:

	PartitionedSampling(partition_dims=[1,2,3,4])

"""
@with_kw struct KDTreePartitioning <: SpacePartitioningAlgorithm
	partition_dims::Union{Array{Int64,1}, Bool} = false
	extend_bounds::Bool = true
end

export KDTreePartitioning


"""
	SpacePartTree

*BAT-internal, not part of stable public API.*

The structure stores a partitioning tree generated by any `SpacePartitioningAlgorithm`.
Variables:

	* terminated_leaf : `true` if the tree node is terminal, `false` otherwise.
	* bounds : Low and high bound of the tree leaf.
	* left_child : The left child of the tree, `false` is the node is terminal.
	* right_child : The right child of the tree, `false` is the node is terminal.
	* cut_axis : Axis along which a cut is performed, `false` if the node is terminal.
	* cut_coordinate : Coordinate at which a cut is performed, `false` if the node is terminal.
	* cost : The sum of the cost functions over leaves.
   * cost_part : The cost functions of the current leaf.
"""
mutable struct SpacePartTree
   terminated_leaf::Bool
   bounds::Array{AbstractFloat}
   left_child::Union{SpacePartTree, Missing}
   right_child::Union{SpacePartTree, Missing}
   cut_axis::Union{Integer, Missing}
   cut_coordinate::Union{AbstractFloat, Missing}
   cost::AbstractFloat
   cost_part::Union{AbstractFloat, Missing}
end

export SpacePartTree
