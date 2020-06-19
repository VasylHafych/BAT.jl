# This file is a part of BAT.jl, licensed under the MIT License (MIT).

abstract type SpacePartitioningAlgorithm end
export SpacePartitioningAlgorithm

"""
	KDTreePartitioning

K-D binary space partitioning algorithm. By default, all parameters are
considered for partitioning. Partition parameters can be specified
manually by using `partition_dims` argument:

	PartitionedSampling(partition_dims=[1,2,3,4])

"""
@with_kw struct KDTreePartitioning <: SpacePartitioningAlgorithm
	partition_dims::Union{Array{Int64,1}, Bool} = false
end

export KDTreePartitioning


"""
	SpacePartTree

The structure stores a partitioning tree generated by any `SpacePartitioningAlgorithm`.
Variables:

	* terminate : `true` if the tree node is terminal, `false` otherwise.
	* bounds : Low and high bound of the tree leaf.
	* left_child : The left child of the tree, `false` is the node is terminal.
	* right_child : The right child of the tree, `false` is the node is terminal.
	* cut_axis : Axis along which a cut is performed, `false` if the node is terminal.
	* cut_coordinate : Coordinate at which a cut is performed, `false` if the node is terminal.
	* cost : The sum of the cost functions over leaves.
   * cost_part : The cost functions of the current leaf.
"""
mutable struct SpacePartTree
   terminate::Bool
   bounds::Array{AbstractFloat}
   left_child::Union{SpacePartTree, Bool}
   right_child::Union{SpacePartTree, Bool}
   cut_axis::Union{Integer, Bool}
   cut_coordinate::Union{AbstractFloat, Bool}
   cost::AbstractFloat
   cost_part::Union{AbstractFloat, Bool}
end

export SpacePartTree