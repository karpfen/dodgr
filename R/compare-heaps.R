#' compare_heaps
#'
#' Perform timing comparison between different kinds of heaps as well as with
#' equivalent \code{igraph} routine \code{distances}. To do this, a random
#' sub-graph containing a defined number of vertices is first selected.
#' Alternatively, this random sub-graph can be pre-generated with the
#' \code{dodgr_sample} function and passed directly.
#'
#' @param graph \code{data.frame} object representing the network graph (or a
#' sub-sample selected with code{dodgr_sample})
#' @param nverts Number of vertices used to generate random sub-graph. If a
#' non-numeric value is given, the whole graph will be used.
#' @param replications Number of replications to be used in comparison
#' @return Result of \code{rbenachmar::benchmark} comparison in
#' \code{data.frame} form.
#'
#' @export
#' @examples
#' graph <- weight_streetnet (hampi)
#' compare_heaps (graph, nverts = 100, replications = 1)
compare_heaps <- function(graph, nverts = 100, replications = 2)
{
    if (is.numeric (nverts))
        graph <- dodgr_sample (graph, nverts = nverts)
    graph <- dodgr_convert_graph (graph)$graph
    graph_contracted <- dodgr_contract_graph (graph)
    graph_contracted <- dodgr_convert_graph (graph_contracted)$graph

    # route only between points on the contracted graph:
    from_id <- unique (graph_contracted$from)
    to_id <- unique (graph_contracted$to)

    # set up igraph:
    fr_col <- find_fr_id_col (graph)
    to_col <- find_to_id_col (graph)
    edges <- cbind (graph [, fr_col], graph [, to_col])
    edges <- as.vector (t (edges))
    igr <- igraph::make_directed_graph (edges)
    igraph::E (igr)$weight <- graph [, find_d_col (graph)]

    rbenchmark::benchmark (
                           d <- dodgr_dists (graph, from = from_id, to = to_id,
                                             heap = "BHeap"),
                           d <- dodgr_dists (graph, from = from_id, to = to_id,
                                             heap = "FHeap"),
                           d <- dodgr_dists (graph, from = from_id, to = to_id,
                                             heap = "TriHeap"),
                           d <- dodgr_dists (graph, from = from_id, to = to_id,
                                             heap = "TriHeapExt"),
                           d <- dodgr_dists (graph, from = from_id, to = to_id,
                                             heap = "Heap23"),
                           d <- dodgr_dists (graph_contracted, from = from_id,
                                             to = to_id, heap = "BHeap"),
                           d <- dodgr_dists (graph_contracted, from = from_id,
                                             to = to_id, heap = "FHeap"),
                           d <- dodgr_dists (graph_contracted, from = from_id,
                                             to = to_id, heap = "TriHeap"),
                           d <- dodgr_dists (graph_contracted, from = from_id,
                                             to = to_id, heap = "TriHeapExt"),
                           d <- dodgr_dists (graph_contracted, from = from_id,
                                             to = to_id, heap = "Heap23"),
                           d <- igraph::distances (igr, v = from_id, to = to_id,
                                              mode = "out"),
                           replications = 10, order = "relative")
}
