# defmodule Bonfire.TaxonomySeeder.RedisGraph do

#   use ActivityPubWeb, :controller

#   alias RedisGraph.{Node, Edge, Graph, QueryResult}

#   def index(conn, _params) do

#     # Create a connection using Redix
#     {:ok, conn} = Redix.start_link("redis://redis:6379")

#     # Create a graph
#     graph = Graph.new(%{
#       name: "social"
#     })

#     # Create a node
#     john = Node.new(%{
#       name: "person",
#       properties: %{
#         name: "John Doe",
#         age: 33,
#         gender: "male",
#         status: "single"
#       }
#     })

#     # Add the node to the graph
#     # The graph and node are returned
#     # The node may be modified if no alias has been set
#     # For this reason, nodes should always be added to the graph
#     # before creating edges between them.
#     {graph, john} = Graph.add_node(graph, john)

#     # Create a second node
#     japan = Node.new(%{
#       name: "country",
#       properties: %{
#         name: "Japan"
#       }
#     })

#     # Add the second node
#     {graph, japan} = Graph.add_node(graph, japan)

#     # Create an edge connecting the two nodes
#     edge = Edge.new(%{
#       src_node: john,
#       dest_node: japan,
#       relation: "visited"
#     })

#     # Add the edge to the graph
#     # If the nodes are not present, an {:error, error} is returned
#     {:ok, graph} = Graph.add_edge(graph, edge)

#     # Commit the graph to the database
#     {:ok, commit_result} = RedisGraph.commit(conn, graph)

#     # Print the transaction statistics
#     #IO.inspect(commit_result.statistics)

#     # Create a query to fetch some data
#     query = "MATCH (p:person)-[v:visited]->(c:country) RETURN p.name, p.age, v.purpose, c.name"

#     # Execute the query
#     {:ok, query_result} = RedisGraph.query(conn, graph.name, query)

#     # Pretty print the results using the Scribe lib
#     IO.inspect(QueryResult.pretty_print(query_result))
#     html(conn,"ok")


#   end
# end
