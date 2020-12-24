defmodule CommonsPub.Utils.Simulate do
  # Basic data

  import Bonfire.Common.Simulation

  alias CommonsPub.{
    Access,
    Activities,
    Communities,
    Collections,
    Flags,
    Follows,
    Features,
    Likes,
    Peers,
    # Uploads,
    # Users,
    Resources,
    Threads,
    Threads.Comments,
    Users.User
  }

  import CommonsPub.Utils.Trendy

  def maybe_assert(value) do
    require ExUnit.Assertions
    ExUnit.Assertions.assert(value)
  end

  def page_info(base \\ %{}) do
    base
    |> Map.put_new_lazy(:start_cursor, &uuid/0)
    |> Map.put_new_lazy(:end_cursor, &uuid/0)
    |> Map.put(:__struct__, Bonfire.GraphQL.PageInfo)
  end

  def long_node_list(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:page_info, &page_info/0)
    |> Map.put_new_lazy(:total_count, &pos_integer/0)
    |> Map.put_new_lazy(:nodes, fn -> long_list(gen) end)
    |> Map.put(:__struct__, Bonfire.GraphQL.NodeList)
  end

  def long_edge_list(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:page_info, &page_info/0)
    |> Map.put_new_lazy(:total_count, &pos_integer/0)
    |> Map.put_new_lazy(:edges, fn -> long_list(fn -> edge(gen) end) end)
    |> Map.put(:__struct__, Bonfire.GraphQL.EdgeList)
  end

  def edge(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:cursor, &uuid/0)
    |> Map.put_new_lazy(:node, gen)
    |> Map.put(:__struct__, Bonfire.GraphQL.Edge)
  end

  # Widely useful schemas:

  def character(base \\ %{}) do
    uname = preferred_username()

    base
    |> Map.put_new_lazy(:preferred_username, fn -> uname end)
    |> Map.put_new_lazy(:canonical_url, fn ->
      CommonsPub.ActivityPub.Utils.generate_actor_url(uname)
    end)
    |> Map.put_new_lazy(:signing_key, &signing_key/0)
  end

  def content_mirror_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:url, &content_url/0)
  end

  def content_upload_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:upload, fn ->
      path = path()

      %Plug.Upload{
        path: path,
        filename: Path.basename(path),
        content_type: content_type()
      }
    end)
  end

  def content_input(base \\ %{}) do
    # gen = Faker.Util.pick([&content_mirror_input/1, &content_upload_input/1])
    # FIXME: need to make fake uploads work
    gen = &content_mirror_input/1
    gen.(base)
  end

  def language(base \\ %{}) do
    base
    # todo: these can't both be right
    |> Map.put_new_lazy(:id, &ulid/0)
    |> Map.put_new_lazy(:iso_code2, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:iso_code3, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:english_name, &Faker.Address.country/0)
    |> Map.put_new_lazy(:local_name, &Faker.Address.country/0)
  end

  def country(base \\ %{}) do
    base
    # todo: these can't both be right
    |> Map.put_new_lazy(:id, &ulid/0)
    |> Map.put_new_lazy(:iso_code2, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:iso_code3, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:english_name, &Faker.Address.country/0)
    |> Map.put_new_lazy(:local_name, &Faker.Address.country/0)
  end

  def peer(base \\ %{}) do
    base
    |> Map.put_new_lazy(:ap_url_base, &ap_url_base/0)
    |> Map.put_new_lazy(:domain, &domain/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def activity(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:verb, &verb/0)
    |> Map.put_new_lazy(:is_local, &bool/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
  end

  def local_user(base \\ %{}) do
    base
    |> Map.put_new_lazy(:email, &email/0)
    |> Map.put_new_lazy(:password, &password/0)
    |> Map.put_new_lazy(:wants_email_digest, &bool/0)
    |> Map.put_new_lazy(:wants_notifications, &bool/0)
    |> Map.put_new_lazy(:is_instance_admin, &falsehood/0)
    |> Map.put_new_lazy(:is_confirmed, &falsehood/0)
  end

  def user(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:website, &website/0)
    |> Map.put_new_lazy(:location, &location/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.merge(character(base))
    |> Map.merge(local_user(base))
  end

  def registration_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("email", &email/0)
    |> Map.put_new_lazy("password", &password/0)
    |> Map.put_new_lazy("preferredUsername", &preferred_username/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
    |> Map.put_new_lazy("location", &location/0)
    |> Map.put_new_lazy("website", &website/0)
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("wantsEmailDigest", &bool/0)
    |> Map.put_new_lazy("wantsNotifications", &bool/0)
  end

  def profile_update_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
    |> Map.put_new_lazy("location", &location/0)
    |> Map.put_new_lazy("website", &website/0)
    |> Map.put_new_lazy("email", &email/0)
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("wantsEmailDigest", &bool/0)
    |> Map.put_new_lazy("wantsNotifications", &bool/0)
  end

  def community(base \\ %{}) do
    base
    # |> Map.put_new_lazy(:primary_language_id, &ulid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.put_new_lazy(:is_featured, &bool/0)
    |> Map.merge(character(base))
  end

  def community_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("preferredUsername", &preferred_username/0)
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
  end

  def community_update_input(base \\ %{}) do
    base
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
  end

  def collection(base \\ %{}) do
    base
    # |> Map.put_new_lazy(:primary_language_id, &ulid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.put_new_lazy(:is_featured, &bool/0)
    |> Map.merge(character(base))
  end

  def collection_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("preferredUsername", &preferred_username/0)
    |> collection_update_input()
  end

  def collection_update_input(base \\ %{}) do
    base
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
  end

  def resource(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:license, &license/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_hidden, &falsehood/0)
  end

  def resource_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
    |> Map.put_new_lazy("license", &license/0)
    |> Map.put("subject", "2290")
    |> Map.put("level", "1100")
    |> Map.put("language", "English")

    # |> Map.put_new_lazy("freeAccess", &maybe_bool/0)
    # |> Map.put_new_lazy("publicAccess", &maybe_bool/0)
    # |> Map.put_new_lazy("learningResourceType", &learning_resource/0)
    # |> Map.put_new_lazy("educationalUse", &educational_use/0)
    # |> Map.put_new_lazy("timeRequired", &pos_integer/0)
    # |> Map.put_new_lazy("typicalAgeRange", &age_range/0)
    # |> Map.put_new_lazy("primaryLanguageId", &primary_language/0)
  end

  def thread(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_locked, &falsehood/0)
    |> Map.put_new_lazy(:is_hidden, &falsehood/0)
  end

  def comment(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:content, &paragraph/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_local, &bool/0)
    |> Map.put_new_lazy(:is_hidden, &falsehood/0)
    |> Map.put_new_lazy(:content, &paragraph/0)
  end

  def comment_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("content", &paragraph/0)
  end

  def like(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
  end

  def like_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def feature_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def flag(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:message, &paragraph/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_resolved, &falsehood/0)
  end

  def flag_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:message, &paragraph/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def follow(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_muted, &falsehood/0)
  end

  def follow_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def block(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_blocked, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_muted, &falsehood/0)
  end

  # def tag(base \\ %{}) do
  #   base
  #   |> Map.put_new_lazy(:is_public, &truth/0)
  #   |> Map.put_new_lazy(:name, &name/0)
  # end

  # def community_role(base \\ %{}) do
  #   base
  # end

  def fake_user(overrides \\ %{}, opts \\ []) when is_map(overrides) and is_list(opts) do
    CommonsPub.Users.register(user(overrides), public_registration: true)
  end

  def fake_user!(overrides \\ %{}, opts \\ []) when is_map(overrides) and is_list(opts) do
    with {:ok, user} <- fake_user(overrides, opts) do
      maybe_confirm_user_email(user, opts)
    end
  end

  defp maybe_confirm_user_email(user, opts) do
    # IO.inspect(opts)

    if Keyword.get(opts, :confirm_email) do
      {:ok, user} = CommonsPub.Users.confirm_email(user)
      user
    else
      user
    end
  end

  def fake_admin!(overrides \\ %{}, opts \\ []) do
    fake_user!(Map.put(overrides, :is_instance_admin, true), opts)
  end

  def fake_register_email_domain_access!(domain \\ domain())
      when is_binary(domain) do
    {:ok, wl} = Access.create_register_email_domain(domain)
    wl
  end

  def fake_register_email_access!(email \\ email())
      when is_binary(email) do
    {:ok, wl} = Access.create_register_email(email)
    wl
  end

  # def fake_language!(overrides \\ %{}) do
  #   overrides
  #   |> Map.get(:id, "en")
  #   |> Localisation.language!()
  # end

  def fake_peer!(overrides \\ %{}) when is_map(overrides) do
    {:ok, peer} = Peers.create(peer(overrides))
    peer
  end

  def fake_activity!(user, context, overrides \\ %{}) do
    {:ok, activity} = Activities.create(user, context, activity(overrides))
    maybe_assert(activity.creator_id == user.id)
    activity
  end

  def fake_character!(overrides \\ %{}) when is_map(overrides) do
    with {:ok, user} <- fake_user(overrides) do
      user.character
    end
  end

  def fake_token!(%{} = user) do
    {:ok, token} = Access.unsafe_put_token(user)
    maybe_assert(token.user_id == user.id)
    token
  end

  def fake_content!(%{} = user, overrides \\ %{}) do
    {:ok, content} =
      CommonsPub.Uploads.upload(
        CommonsPub.Uploads.ResourceUploader,
        user,
        content_input(overrides),
        %{}
      )

    maybe_assert(content.uploader_id == user.id)
    content
  end

  def fake_community!(user, context \\ nil, overrides \\ %{})

  def fake_community!(%User{} = user, context, %{} = overrides) do
    {:ok, community} = Communities.create(user, context, community(overrides))
    maybe_assert(community.creator_id == user.id)
    community
  end

  def fake_collection!(user, context \\ nil, overrides \\ %{})

  def fake_collection!(user, context, overrides)
      when is_map(overrides) and is_nil(context) do
    {:ok, collection} = Collections.create(user, collection(overrides))
    maybe_assert(collection.creator_id == user.id)
    collection
  end

  def fake_collection!(user, context, overrides) when is_map(overrides) do
    {:ok, collection} = Collections.create(user, context, collection(overrides))
    maybe_assert(collection.creator_id == user.id)
    collection
  end

  def fake_resource!(user, context \\ nil, overrides \\ %{}) when is_map(overrides) do
    attrs =
      overrides
      |> resource()
      |> Map.put(:content_id, fake_content!(user, overrides).id)

    {:ok, resource} = Resources.create(user, context, attrs)
    maybe_assert(resource.creator_id == user.id)
    # maybe_assert resource.context_id == context.id
    resource
  end

  def fake_thread!(user, context, overrides \\ %{})

  def fake_thread!(user, nil, overrides) when is_map(overrides) do
    {:ok, thread} = Threads.create(user, thread(overrides))
    maybe_assert(thread.creator_id == user.id)
    thread
  end

  def fake_thread!(user, context, overrides) when is_map(overrides) do
    {:ok, thread} = Threads.create(user, thread(overrides), context)
    maybe_assert(thread.creator_id == user.id)
    thread
  end

  def fake_comment!(user, thread, overrides \\ %{}) when is_map(overrides) do
    {:ok, comment} = Comments.create(user, thread, comment(overrides))
    maybe_assert(comment.creator_id == user.id)
    comment
  end

  def fake_reply!(user, thread, comment, overrides \\ %{}) when is_map(overrides) do
    fake = comment(Map.put_new(overrides, :in_reply_to, comment.id))
    {:ok, comment} = Comments.create(user, thread, fake)
    maybe_assert(comment.creator_id == user.id)
    comment
  end

  def some_fake_users!(opts \\ %{}, some_arg) do
    some(some_arg, fn -> fake_user!(opts) end)
  end

  def some_fake_communities!(opts \\ %{}, some_arg, users) do
    flat_pam(users, &some(some_arg, fn -> fake_community!(&1, opts) end))
  end

  def some_fake_resources!(opts \\ %{}, some_arg, users, collections) do
    flat_pam_product_some(users, collections, some_arg, &fake_resource!(&1, &2, opts))
  end

  def some_fake_collections!(opts \\ %{}, some_arg, users, communities) do
    flat_pam_product_some(users, communities, some_arg, &fake_collection!(&1, &2, opts))
  end

  def some_randomer_flags!(opts \\ %{}, some_arg, context) do
    users = some_fake_users!(opts, some_arg)
    pam(users, &flag!(&1, context, opts))
  end

  def some_randomer_follows!(opts \\ %{}, some_arg, context) do
    users = some_fake_users!(opts, some_arg)
    pam(users, &follow!(&1, context, opts))
  end

  def some_randomer_likes!(opts \\ %{}, some_arg, context) do
    users = some(some_arg, &fake_user!/0)
    pam(users, &like!(&1, context, opts))
  end

  def like!(user, context, args \\ %{}) do
    {:ok, like} = Likes.create(user, context, like_input(args))
    maybe_assert(like.creator_id == user.id)
    maybe_assert(like.context_id == context.id)
    like
  end

  def flag!(user, context, args \\ %{}) do
    {:ok, flag} = Flags.create(user, context, flag_input(args))
    maybe_assert(flag.creator_id == user.id)
    maybe_assert(flag.context_id == context.id)
    flag
  end

  def follow!(user, context, args \\ %{}) do
    {:ok, follow} = Follows.create(user, context, follow_input(args))
    maybe_assert(follow.creator_id == user.id)
    maybe_assert(follow.context_id == context.id)
    follow
  end

  def feature!(user, context, args \\ %{}) do
    {:ok, feature} = Features.create(user, context, feature_input(args))
    maybe_assert(feature.creator_id == user.id)
    maybe_assert(feature.context_id == context.id)
    feature
  end
end
