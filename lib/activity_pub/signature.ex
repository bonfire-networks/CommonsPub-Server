defmodule MoodleNet.Signature do
  use Bitwise

  def decode_key("RSA." <> magickey) do
    make_integer = fn bin ->
      list = :erlang.binary_to_list(bin)
      Enum.reduce(list, 0, fn el, acc -> acc <<< 8 ||| el end)
    end

    [modulus, exponent] =
      magickey
      |> String.split(".")
      |> Enum.map(fn n -> Base.url_decode64!(n, padding: false) end)
      |> Enum.map(make_integer)

    {:RSAPublicKey, modulus, exponent}
  end

  def encode_key({:RSAPublicKey, modulus, exponent}) do
    modulus_enc = :binary.encode_unsigned(modulus) |> Base.url_encode64()
    exponent_enc = :binary.encode_unsigned(exponent) |> Base.url_encode64()

    "RSA.#{modulus_enc}.#{exponent_enc}"
  end

  def ensure_keys_present(user) do
    info = user.info || %{}

    if info["keys"] do
      {:ok, user}
    else
      {:ok, pem} = generate_rsa_pem()
      info = Map.put(info, "keys", pem)

      Ecto.Changeset.change(user, info: info)
      |> MoodleNet.User.update_and_set_cache()
    end
  end

  def keys_from_pem(pem) do
    [private_key_code] = :public_key.pem_decode(pem)
    private_key = :public_key.pem_entry_decode(private_key_code)
    {:RSAPrivateKey, _, modulus, exponent, _, _, _, _, _, _, _} = private_key
    public_key = {:RSAPublicKey, modulus, exponent}
    {:ok, private_key, public_key}
  end

  # Native generation of RSA keys is only available since OTP 20+ and in default build conditions
  # We try at compile time to generate natively an RSA key otherwise we fallback on the old way.
  try do
    _ = :public_key.generate_key({:rsa, 2048, 65537})

    def generate_rsa_pem do
      key = :public_key.generate_key({:rsa, 2048, 65537})
      entry = :public_key.pem_entry_encode(:RSAPrivateKey, key)
      pem = :public_key.pem_encode([entry]) |> String.trim_trailing()
      {:ok, pem}
    end
  rescue
    _ ->
      def generate_rsa_pem do
        port = Port.open({:spawn, "openssl genrsa"}, [:binary])

        {:ok, pem} =
          receive do
            {^port, {:data, pem}} -> {:ok, pem}
          end

        Port.close(port)

        if Regex.match?(~r/RSA PRIVATE KEY/, pem) do
          {:ok, pem}
        else
          :error
        end
      end
  end

end
