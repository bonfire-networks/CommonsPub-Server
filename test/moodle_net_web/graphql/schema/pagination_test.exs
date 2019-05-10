defmodule MoodleNetWeb.GraphQL.PaginationTest do
  use MoodleNetWeb.ConnCase, async: true

  @moduletag format: :json

  @tag :user
  test "paginates by creation", %{conn: conn, actor: actor} do
    a = Factory.community(actor)
    b = Factory.community(actor)

    query = """
    {
      communities {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => nil
             },
             "nodes" => [b_map, a_map]
           } = community_page

    assert a_map == %{
      "id" => a.id,
      "name" => a.name["und"]
    }

    assert b_map == %{
      "id" => b.id,
      "name" => b.name["und"]
    }

    query = """
    {
      communities(limit: 1) {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => cursor
             },
             "nodes" => [^b_map]
           } = community_page

    query = """
    {
      communities(limit: 1, after: #{cursor}) {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => cursor
             },
             "nodes" => [^a_map]
           } = community_page

    query = """
    {
      communities(limit: 1, after: #{cursor}) {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => nil
             },
             "nodes" => []
           } = community_page

    query = """
    {
      communities(limit: 1, before: #{cursor}) {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => cursor
             },
             "nodes" => [^a_map]
           } = community_page

    query = """
    {
      communities(limit: 1, before: #{cursor}) {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => cursor
             },
             "nodes" => [^b_map]
           } = community_page

    query = """
    {
      communities(limit: 1, before: #{cursor}) {
        pageInfo {
          startCursor
          endCursor
        }
        nodes {
          id
          name
        }
      }
    }
    """

    assert community_page =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => cursor
             },
             "nodes" => []
           } = community_page

    assert cursor
  end

  @tag :user
  test "paginates by collection insertion", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
    {
      community(id: "#{community.id}") {
        members(limit: 1) {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => cursor
             },
             "edges" => [
               %{
                 "cursor" => cursor,
                 "node" => actor_map
               }
             ]
           } = community_map["members"]

    assert actor_map == %{
             "id" => actor.id,
             "name" => actor.name["und"],
           }

    other_actor = Factory.actor()
    MoodleNet.join_community(other_actor, community)

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => cursor
             },
             "edges" => [
               %{
                 "cursor" => cursor,
                 "node" => other_actor_map
               }
             ]
           } = community_map["members"]

    assert cursor

    assert other_actor_map == %{
             "id" => other_actor.id,
             "name" => other_actor.name["und"],
           }

    query = """
    {
      community(id: "#{community.id}") {
        members(limit: 1, after: #{cursor}) {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => cursor
             },
             "edges" => [
               %{
                 "cursor" => cursor,
                 "node" => ^actor_map
               }
             ]
           } = community_map["members"]

    query = """
    {
      community(id: "#{community.id}") {
        members(limit: 1, after: #{cursor}) {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => nil
             },
             "edges" => []
           } = community_map["members"]

    assert cursor

    query = """
    {
      community(id: "#{community.id}") {
        members(limit: 1, before: #{cursor}) {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => cursor
             },
             "edges" => [
               %{
                 "cursor" => cursor,
                 "node" => ^actor_map
               }
             ]
           } = community_map["members"]

    query = """
    {
      community(id: "#{community.id}") {
        members(limit: 1, before: #{cursor}) {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => cursor,
               "endCursor" => cursor
             },
             "edges" => [
               %{
                 "cursor" => cursor,
                 "node" => ^other_actor_map
               }
             ]
           } = community_map["members"]

    query = """
    {
      community(id: "#{community.id}") {
        members(limit: 1, before: #{cursor}) {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              name
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => cursor
             },
             "edges" => []
           } = community_map["members"]

    assert cursor
  end

  @tag :user
  test "works when asking only total count", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
    {
      community(id: "#{community.id}") {
        members {
          totalCount
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("members")
             |> Map.fetch!("totalCount")
  end

  @tag :user
  test "works when asking only page info", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
    {
      community(id: "#{community.id}") {
        members {
          pageInfo {
            startCursor
            endCursor
          }
        }
      }
    }
    """

    assert %{"startCursor" => nil, "endCursor" => nil} =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("members")
             |> Map.fetch!("pageInfo")
  end

  @tag :user
  test "works when asking only edges", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
    {
      community(id: "#{community.id}") {
        members {
          edges {
            cursor
          }
        }
      }
    }
    """

    assert [%{"cursor" => _}] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("members")
             |> Map.fetch!("edges")
  end
end
