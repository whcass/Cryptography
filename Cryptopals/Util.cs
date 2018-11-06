using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
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

			foreach (char c in data)
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

		public static int GetHammingDistance(byte[] a, byte[] b)
		{
			int distance = 0;
			for (int i = 0; i < a.Length;i++)
			{
				if (a[i] != b[i])
				{
					distance++;
				}
			}

			return distance;
		}

		public static byte[] Slice(byte[] arr, int start, int end)
		{
			// Handles negative ends.
			if (end < 0)
			{
				end = arr.Length + end;
			}
			int len = end - start;

			// Return new array.
			byte[] res = new byte[len];
			for (int i = 0; i < len; i++)
			{
				res[i] = arr[i + start];
			}
			return res;
		}

		public static byte[] SubArray(byte[] data, int index, int length)
		{
			byte[] result = new byte[length];
			Array.Copy(data, index, result, 0, length);
			return result;
		}

		public static string GenerateCharArray()
		{
			string s = "";
			for (int i = 32; i <= 126; i++)
			{
				s += Convert.ToChar(i);
			}

			return s;
		}

	}
}