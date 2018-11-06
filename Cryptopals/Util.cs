using System;
using System.Text;
using System.Text.RegularExpressions;

namespace Cryptopals
{
	public class Util
	{
		public static int characterAnalysis(char[] inArray)
		{
			Regex rx = new Regex(@"[ETAOIN SHRDLU]",RegexOptions.IgnoreCase);
			int matches = 0;
			foreach (char c in inArray)
			{
				if (rx.IsMatch(c.ToString()))
				{
					matches++;
				}
			}
			return matches;
		}

		public static string StringToBinary(string data)
		{
			StringBuilder sb = new StringBuilder();

			foreach (char c in data.ToCharArray())
			{
				sb.Append(Convert.ToString(c, 2).PadLeft(8, '0'));
			}
			return sb.ToString();
		}

		public static int GetHammingDistance(string a, string b)
		{
			byte[] aBytes = Encoding.Default.GetBytes(StringToBinary(a));
			byte[] bBytes = Encoding.Default.GetBytes(StringToBinary(b));
			int distance = 0;
			for (int i = 0; i < aBytes.Length;i++)
			{
				if (aBytes[i] != bBytes[i])
				{
					distance++;
				}
			}

			return distance;

		}
	}
}