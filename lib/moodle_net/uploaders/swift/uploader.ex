defmodule MoodleNet.Uploaders.Swift do
  @behaviour MoodleNet.Uploaders.Uploader

  def put_file(name, uuid, tmp_path, content_type, _should_dedupe) do
    {:ok, file_data} = File.read(tmp_path)
    remote_name = "#{uuid}/#{name}"

    MoodleNet.Uploaders.Swift.Client.upload_file(remote_name, file_data, content_type)
  end
end
