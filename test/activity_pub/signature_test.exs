defmodule MoodleNet.SignatureTest do
  use MoodleNet.DataCase, async: true
  alias MoodleNet.Signature

  @magickey "RSA.pu0s-halox4tu7wmES1FVSx6u-4wc0YrUFXcqWXZG4-27UmbCOpMQftRCldNRfyA-qLbz-eqiwQhh-1EwUvjsD4cYbAHNGHwTvDOyx5AKthQUP44ykPv7kjKGh3DWKySJvcs9tlUG87hlo7AvnMo9pwRS_Zz2CacQ-MKaXyDepk=.AQAB"

  @wrong_magickey "RSA.pu0s-halox4tu7wmES1FVSx6u-4wc0YrUFXcqWXZG4-27UmbCOpMQftRCldNRfyA-qLbz-eqiwQhh-1EwUvjsD4cYbAHNGHwTvDOyx5AKthQUP44ykPv7kjKGh3DWKySJvcs9tlUG87hlo7AvnMo9pwRS_Zz2CacQ-MKaXyDepk=.AQAA"

  @magickey_friendica "RSA.AMwa8FUs2fWEjX0xN7yRQgegQffhBpuKNC6fa5VNSVorFjGZhRrlPMn7TQOeihlc9lBz2OsHlIedbYn2uJ7yCs0.AQAB"

  test "generates an RSA private key pem" do
    {:ok, key} = Signature.generate_rsa_pem()
    assert is_binary(key)
    assert Regex.match?(~r/RSA/, key)
  end

  test "it encodes a magic key from a public key" do
    key = Signature.decode_key(@magickey)
    magic_key = Signature.encode_key(key)

    assert @magickey == magic_key
  end

  test "it decodes a friendica public key" do
    assert _key = Signature.decode_key(@magickey_friendica)
  end

  test "returns a public and private key from a pem" do
    pem = File.read!("test/fixtures/private_key.pem")
    {:ok, private, public} = Signature.keys_from_pem(pem)

    assert elem(private, 0) == :RSAPrivateKey
    assert elem(public, 0) == :RSAPublicKey
  end
end
