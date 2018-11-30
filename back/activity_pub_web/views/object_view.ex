defmodule ActivityPub.ObjectView do
  use ActivityPubWeb, :view

  def render("object.json", %{object: object}) do
    %{
      "@context": [
        "https://www.w3.org/ns/activitystreams",
        "https://w3id.org/security/v1",
        %{
          "manuallyApprovesFollowers" => "as:manuallyApprovesFollowers",
          "sensitive" => "as:sensitive",
          "Hashtag" => "as:Hashtag",
          "toot" => "http://joinmastodon.org/ns#",
          "Emoji" => "toot:Emoji"
        }
      ],
      # id: object[:uri],
      # type: object[:type],
      # # attachment: object[:attachment],
      # # attributedTo: object[:attributedTo],
      # # audience: object[:audience],
      # content: object[:content],
      # # context: object[:context],
      # name: object[:name],
      # # endTime: object[:endTime],
      # # generator: object[:generator],
      # icon: object[:icon],
      # image: object[:image],
      # # inReplyTo: object[:inReplyTo],
      # # location: object[:location],
      # # preview: object[:preview],
      # published: object[:published],
      # # replies: object[:replies],
      # # startTime: object[:startTime],
      # summary: object[:summary],
      # # tag: object[:tag],
      # # updated: object[:updated],
      # url: object[:url],
      # to: object[:to],
      # bto: object[:bto],
      # cc: object[:cc],
      # bcc: object[:bcc]
      # # mediaType: object[:mediaType],
      # # duration: object[:duration],
    }
  end
end
