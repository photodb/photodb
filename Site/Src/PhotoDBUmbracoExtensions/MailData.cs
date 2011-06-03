using System.Collections.Generic;
using System.Text;

namespace PhotoDBUmbracoExtensions
{
    public class MailData
    {
        private Dictionary<string, string> mailFields = new Dictionary<string, string>();

        public void Add(string key, string value)
        {
            mailFields.Add(key, value);
        }

        public string BuildData(string mask)
        {
            StringBuilder sb = new StringBuilder();

            foreach(KeyValuePair<string, string> pair in mailFields)
                sb.AppendFormat(mask, pair.Key, pair.Value);

            return sb.ToString();
        }
    }
}
