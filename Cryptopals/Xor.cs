using System;

namespace Cryptopals
{
	public class Xor
	{
		public static string FixedXOR(string input, string against)
		{
			byte[] hexInput = Hex.HexStringToHex(input);
			byte[] hexAgainst = Hex.HexStringToHex(against);

			byte[] result = new byte[hexInput.Length];
			for (int i = 0; i < hexInput.Length; i++)
			{
				result[i] = (byte) (hexInput[i] ^ hexAgainst[i]);
			}

			string hex = Hex.ConvertHexToString(result);

			return hex;
		}

		public static string repeatingKeyXorEncode(string input, string key)
        {
            byte[] hexInput = Hex.HexStringToHex(Hex.stringToHex(input));

            byte[] hexKey = Hex.HexStringToHex(Hex.stringToHex(key));
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

		public static void fileSingleByteXorDecode(string fileName)
        {

            string[] lines = System.IO.File.ReadAllLines(fileName);
            var s = Util.GenerateCharArray();
	        char[] charArray = s.ToCharArray();
            foreach (string line in lines)
            {
                singeByteXorDecode(charArray, line);
            }
        }


		public static char singeByteXorDecode(char[] charArray, string input)
		{
			int bestMach = 0;
			char key = 'E';
            foreach (char c in charArray)
            {
                char[] result = singleByteXor(input, c);
                int matches = Util.characterAnalysis(result);
                if (matches > bestMach)
                {
	                bestMach = matches;
	                key = c;
	                //Console.WriteLine("Possible match found using - " + c);
	                //Console.WriteLine(new string(result));
	                //Console.WriteLine("Maches: " + matches + "\n");
                }
            }

			return key;
		}

		public static char[] singleByteXor(string input, char c)
        {
            byte[] hexInput = Hex.HexStringToHex(input);
            char[] result = new char[hexInput.Length];

            for (int i = 0; i < hexInput.Length; i++)
            {
                result[i] = Convert.ToChar(hexInput[i] ^ c);
            }

            return result;

        }
	}
}