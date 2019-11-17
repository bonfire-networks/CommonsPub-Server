# Do not put a license comment here, see moduledoc.
defmodule Mootils.Bose64 do
  @moduledoc """
  Bose64 is a Base64 dialect that preserves binary bitwise sort order.

  This implementation shares exactly the performance characteristics
  of the elixir `Base` module's base64 encoding/decoding, since it is
  largely copy and pasted therefrom.

  Named after Jagadish Chandra Bose, noted Bengali polymath and one of
  the founding fathers of radio science.

  Alphabet

      | Value | Encoding | Value | Encoding | Value | Encoding | Value | Encoding |
      |------:|---------:|------:|---------:|------:|---------:|------:|---------:|
      |      0|         0|     17|         H|     34|         Y|     51|         o|
      |      1|         1|     18|         I|     35|         Z|     52|         p|
      |      2|         2|     19|         J|     36|         _|     53|         q|
      |      3|         3|     20|         K|     37|         a|     54|         r|
      |      4|         4|     21|         L|     38|         b|     55|         s|
      |      5|         5|     22|         M|     39|         c|     56|         t|
      |      6|         6|     23|         N|     40|         d|     57|         u|
      |      7|         7|     24|         O|     41|         e|     58|         v|
      |      8|         8|     25|         P|     42|         f|     59|         w|
      |      9|         9|     26|         Q|     43|         g|     60|         x|
      |     10|         A|     27|         R|     44|         h|     61|         y|
      |     11|         B|     28|         S|     45|         i|     62|         z|
      |     12|         C|     29|         T|     46|         j|     63|         ~|
      |     13|         D|     30|         U|     47|         k|       |          |
      |     14|         E|     31|         V|     48|         l|  (pad)|         =|
      |     15|         F|     32|         W|     49|         m|       |          |
      |     16|         G|     33|         X|     50|         n|       |          |
  
  """
  alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~'

  import Bitwise
  
  defmacrop encode_pair(alphabet, case, value) do
    quote do
      case unquote(value) do
        unquote(encode_pair_clauses(alphabet, case))
      end
    end
  end

  defp encode_pair_clauses(alphabet, case) when case in [:sensitive, :upper] do
    shift = shift(alphabet)

    alphabet
    |> Enum.with_index()
    |> encode_clauses(shift)
  end

  defp encode_pair_clauses(alphabet, :lower) do
    shift = shift(alphabet)

    alphabet
    |> Stream.map(fn c -> if c in ?A..?Z, do: c - ?A + ?a, else: c end)
    |> Enum.with_index()
    |> encode_clauses(shift)
  end

  defp shift(alphabet) do
    alphabet
    |> length()
    |> :math.log2()
    |> round()
  end

  defp encode_clauses(alphabet, shift) do
    for {encoding1, value1} <- alphabet,
        {encoding2, value2} <- alphabet do
      encoding = bsl(encoding1, 8) + encoding2
      value = bsl(value1, shift) + value2
      [clause] = quote(do: (unquote(value) -> unquote(encoding)))
      clause
    end
  end

  defmacrop decode_char(alphabet, case, encoding) do
    quote do
      case unquote(encoding) do
        unquote(decode_char_clauses(alphabet, case))
      end
    end
  end

  defp decode_char_clauses(alphabet, case) when case in [:sensitive, :upper] do
    clauses =
      alphabet
      |> Enum.with_index()
      |> decode_clauses()

    clauses ++ bad_digit_clause()
  end

  defp decode_char_clauses(alphabet, :lower) do
    {uppers, rest} =
      alphabet
      |> Stream.with_index()
      |> Enum.split_with(fn {encoding, _} -> encoding in ?A..?Z end)

    lowers = Enum.map(uppers, fn {encoding, value} -> {encoding - ?A + ?a, value} end)

    if length(uppers) > length(rest) do
      decode_mixed_clauses(lowers, rest)
    else
      decode_mixed_clauses(rest, lowers)
    end
  end

  defp decode_char_clauses(alphabet, :mixed) when length(alphabet) == 16 do
    alphabet = Enum.with_index(alphabet)

    lowers =
      alphabet
      |> Stream.filter(fn {encoding, _} -> encoding in ?A..?Z end)
      |> Enum.map(fn {encoding, value} -> {encoding - ?A + ?a, value} end)

    decode_mixed_clauses(alphabet, lowers)
  end

  defp decode_char_clauses(alphabet, :mixed) when length(alphabet) == 32 do
    clauses =
      alphabet
      |> Stream.with_index()
      |> Enum.flat_map(fn {encoding, value} = pair ->
        if encoding in ?A..?Z do
          [pair, {encoding - ?A + ?a, value}]
        else
          [pair]
        end
      end)
      |> decode_clauses()

    clauses ++ bad_digit_clause()
  end

  defp decode_mixed_clauses(first, second) do
    first_clauses = decode_clauses(first)
    second_clauses = decode_clauses(second) ++ bad_digit_clause()

    join_clause =
      quote do
        encoding ->
          case encoding do
            unquote(second_clauses)
          end
      end

    first_clauses ++ join_clause
  end

  defp decode_clauses(alphabet) do
    for {encoding, value} <- alphabet do
      [clause] = quote(do: (unquote(encoding) -> unquote(value)))
      clause
    end
  end

  defp bad_digit_clause() do
    quote do
      c ->
        raise ArgumentError,
              "non-alphabet digit found: #{inspect(<<c>>, binaries: :as_strings)} (byte #{c})"
    end
  end

  defp maybe_pad(body, "", _, _), do: body
  defp maybe_pad(body, tail, false, _), do: body <> tail

  defp maybe_pad(body, tail, _, group_size) do
    case group_size - rem(byte_size(tail), group_size) do
      ^group_size -> body <> tail
      6 -> body <> tail <> "======"
      5 -> body <> tail <> "====="
      4 -> body <> tail <> "===="
      3 -> body <> tail <> "==="
      2 -> body <> tail <> "=="
      1 -> body <> tail <> "="
    end
  end

  @doc """
  Encodes a binary string into a bose64 encoded string.

  Accepts `padding: false` option which will omit padding from
  the output string.

  ## Examples

      iex> Bose64.encode("foobar")
      "Zm9vYmFy"

      iex> Bose64.encode("foob")
      "Zm9vYg=="

      iex> Bose64.encode("foob", padding: false)
      "Zm9vYg"

  """
  @spec encode(binary, keyword) :: binary
  def encode(data, opts \\ []) when is_binary(data) do
    pad? = Keyword.get(opts, :padding, true)
    do_encode(data, pad?)
  end

  @doc """
  Decodes a bose64 encoded string into a binary string.

  Accepts `ignore: :whitespace` option which will ignore all the
  whitespace characters in the input string.

  Accepts `padding: false` option which will ignore padding from
  the input string.

  ## Examples

      iex> Bose64.decode("Zm9vYmFy")
      {:ok, "foobar"}

      iex> Bose64.decode("Zm9vYmFy\\n", ignore: :whitespace)
      {:ok, "foobar"}

      iex> Bose64.decode("Zm9vYg==")
      {:ok, "foob"}

      iex> Bose64.decode("Zm9vYg", padding: false)
      {:ok, "foob"}

  """
  @spec decode(binary, keyword) :: {:ok, binary} | :error
  def decode(string, opts \\ []) when is_binary(string) do
    {:ok, decode!(string, opts)}
  rescue
    ArgumentError -> :error
  end

  @doc """
  Decodes a bose64 encoded string into a binary string.

  Accepts `ignore: :whitespace` option which will ignore all the
  whitespace characters in the input string.

  Accepts `padding: false` option which will ignore padding from
  the input string.

  An `ArgumentError` exception is raised if the padding is incorrect or
  a non-alphabet character is present in the string.

  ## Examples

      iex> Bose64.decode!("Zm9vYmFy")
      "foobar"

      iex> Bose64.decode!("Zm9vYmFy\\n", ignore: :whitespace)
      "foobar"

      iex> Bose64.decode!("Zm9vYg==")
      "foob"

      iex> Bose64.decode!("Zm9vYg", padding: false)
      "foob"

  """
  @spec decode!(binary, keyword) :: binary
  def decode!(string, opts \\ []) when is_binary(string) do
    pad? = Keyword.get(opts, :padding, true)
    string |> remove_ignored(opts[:ignore]) |> do_decode(pad?)
  end

  defp remove_ignored(string, nil), do: string

  defp remove_ignored(string, :whitespace) do
    for <<char::8 <- string>>, char not in '\s\t\r\n', into: <<>>, do: <<char::8>>
  end

  pair = :"enc_pair"
  char = :"enc_char"
  do_encode = :"do_encode"

  defp unquote(pair)(value) do
    encode_pair(unquote(alphabet), :sensitive, value)
  end

  defp unquote(char)(value) do
    value
    |> unquote(pair)()
    |> band(0x00FF)
  end

  defp unquote(do_encode)(<<>>, _), do: <<>>

  defp unquote(do_encode)(data, pad?) do
    split = 6 * div(byte_size(data), 6)
    <<main::size(split)-binary, rest::binary>> = data

    main =
      for <<c1::12, c2::12, c3::12, c4::12 <- main>>, into: <<>> do
        <<
          unquote(pair)(c1)::16,
          unquote(pair)(c2)::16,
          unquote(pair)(c3)::16,
          unquote(pair)(c4)::16
        >>
      end

    tail =
      case rest do
        <<c1::12, c2::12, c3::12, c::4>> ->
          <<
            unquote(pair)(c1)::16,
            unquote(pair)(c2)::16,
            unquote(pair)(c3)::16,
            unquote(char)(bsl(c, 2))::8
          >>

        <<c1::12, c2::12, c3::8>> ->
          <<unquote(pair)(c1)::16, unquote(pair)(c2)::16, unquote(pair)(bsl(c3, 4))::16>>

        <<c1::12, c2::12>> ->
          <<unquote(pair)(c1)::16, unquote(pair)(c2)::16>>

        <<c1::12, c2::4>> ->
          <<unquote(pair)(c1)::16, unquote(char)(bsl(c2, 2))::8>>

        <<c1::8>> ->
          <<unquote(pair)(bsl(c1, 4))::16>>

        <<>> ->
          <<>>
      end

    maybe_pad(main, tail, pad?, 4)
  end

  fun = :"dec"
  do_decode = :"do_decode"

  defp unquote(fun)(encoding) do
    decode_char(unquote(alphabet), :sensitive, encoding)
  end

  defp unquote(do_decode)(<<>>, _), do: <<>>

  defp unquote(do_decode)(string, pad?) do
    segs = div(byte_size(string) + 7, 8) - 1
    <<main::size(segs)-binary-unit(64), rest::binary>> = string

    main =
    for <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8 <- main>>, into: <<>> do
        <<
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6,
          unquote(fun)(c5)::6,
          unquote(fun)(c6)::6,
          unquote(fun)(c7)::6,
          unquote(fun)(c8)::6
        >>
      end

    case rest do
      <<c1::8, c2::8, ?=, ?=>> ->
        <<main::bits, unquote(fun)(c1)::6, bsr(unquote(fun)(c2), 4)::2>>

      <<c1::8, c2::8, c3::8, ?=>> ->
        <<main::bits, unquote(fun)(c1)::6, unquote(fun)(c2)::6, bsr(unquote(fun)(c3), 2)::4>>

      <<c1::8, c2::8, c3::8, c4::8>> ->
        <<
          main::bits,
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6
        >>

      <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, ?=, ?=>> ->
        <<
          main::bits,
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6,
          unquote(fun)(c5)::6,
          bsr(unquote(fun)(c6), 4)::2
        >>

      <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, ?=>> ->
        <<
          main::bits,
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6,
          unquote(fun)(c5)::6,
          unquote(fun)(c6)::6,
          bsr(unquote(fun)(c7), 2)::4
        >>

      <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8>> ->
        <<
          main::bits,
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6,
          unquote(fun)(c5)::6,
          unquote(fun)(c6)::6,
          unquote(fun)(c7)::6,
          unquote(fun)(c8)::6
        >>

      <<c1::8, c2::8>> when not pad? ->
        <<main::bits, unquote(fun)(c1)::6, bsr(unquote(fun)(c2), 4)::2>>

      <<c1::8, c2::8, c3::8>> when not pad? ->
        <<main::bits, unquote(fun)(c1)::6, unquote(fun)(c2)::6, bsr(unquote(fun)(c3), 2)::4>>

      <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8>> when not pad? ->
        <<
          main::bits,
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6,
          unquote(fun)(c5)::6,
          bsr(unquote(fun)(c6), 4)::2
        >>

      <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8>> when not pad? ->
        <<
          main::bits,
          unquote(fun)(c1)::6,
          unquote(fun)(c2)::6,
          unquote(fun)(c3)::6,
          unquote(fun)(c4)::6,
          unquote(fun)(c5)::6,
          unquote(fun)(c6)::6,
          bsr(unquote(fun)(c7), 2)::4
        >>

      _ ->
       raise ArgumentError, "incorrect padding"
    end
  end

end
