using System;
using System.Text;

namespace Cryptopals
{
	public class Hex
	{
		public static string HexToBase64(string input)
		{
			return Convert.ToBase64String(HexStringToHex(input));
		}

		public static string Base64ToHex(string input)
		{
			byte[] hexBytes = Convert.FromBase64String(input);
			string hex = BitConverter.ToString(hexBytes).Replace("-","").ToLower();
			return hex;
		}

		public static byte[] HexStringToHex(string inputHex)
		{
			var resultArray = new byte[inputHex.Length / 2];
			for (int i = 0; i < resultArray.Length; i++)
			{
				resultArray[i] = Convert.ToByte(inputHex.Substring(i * 2, 2), 16);
			}
			return resultArray;
		}

		public static string stringToHex(string input)
		{
			byte[] bytes = Encoding.Default.GetBytes(input);
			string hexString = BitConverter.ToString(bytes);
			return hexString.Replace("-", "");
		}

		public static string repeatingKeyXorEncode(string input, string key)
        {
            byte[] hexInput = HexStringToHex(stringToHex(input));
            byte[] hexKey = HexStringToHex(stringToHex(key));
            byte[] result = new byte[hexInput.Length];
            for (int i = 0; i < hexInput.Length; i++)
            {
                byte k = hexKey[i % hexKey.Length];
                result[i] = (byte)(hexInput[i] ^ k);
            }
            string resultString = BitConverter.ToString(result);
            resultString = resultString.Replace("-", "");
            return resultString.ToLower();
        }

		public static string repeatingKeyXorDecode(string input, string key)
		{
			byte[] hexInput = HexStringToHex(input);
			char[] charKey = key.ToCharArray();
			char[] result = new char[hexInput.Length];
			for (int i = 0; i < hexInput.Length; i++)
			{
				char k = charKey[i % charKey.Length];
				result[i] = Convert.ToChar(hexInput[i] ^ k);
			}

			return new string(result);
		}

		public static void fileSingleByteXorDecode(string fileName)
        {

            string[] lines = System.IO.File.ReadAllLines(fileName);
            string s = "";
            for (int i = 32; i <= 126; i++)
            {
                s += Convert.ToChar(i);
            }
            char[] charArray = s.ToCharArray();
            foreach (string line in lines)
            {
                SingleByteXorDecode(charArray, line);
            }
        }

		public static void SingleByteXorDecode(char[] charArray, string input)
        {
            foreach (char c in charArray)
            {
                char[] result = singleByteXor(input, c);
                int matches = Util.characterAnalysis(result);
                if (matches > 20)
                {
                    Console.WriteLine("Possible match found using - " + c);
                    Console.WriteLine(new string(result));
                    Console.WriteLine("Maches: " + matches + "\n");
                }
            }
        }

		public static char[] singleByteXor(string input, char c)
        {
            byte[] hexInput = HexStringToHex(input);
            char[] result = new char[hexInput.Length];

            for (int i = 0; i < hexInput.Length; i++)
            {
                result[i] = Convert.ToChar(hexInput[i] ^ c);
            }

            return result;

        }


		public static string ConvertHexToString(byte[] input)
		{
			return BitConverter.ToString(input).Replace("-", "").ToLower();
		}

		public static byte[] HexToBytes(string input)
		{
			var arr = new string[input.Length/2];

			for (var i = 0; i < input.Length; i += 2)
			{
				arr[i/2] = input.Substring(i, 2);
			}

			return Array.ConvertAll(arr, s => Convert.ToByte(s, 16));
		}
	}
}