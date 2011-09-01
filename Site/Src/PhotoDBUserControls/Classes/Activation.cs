using PhotoDBDatabase.Classes;
using PhotoDBUmbracoExtensions;

namespace PhotoDBUserControls.Classes
{
    public class Activation
    {
        public static void NotifyActivation(string firstName, string lastName, string email, string phone, string country, string city, string address,
            string programCode, string activationCode, string programVersion, bool isFull)
        {
            ActivationManager.NewFreeActivation(firstName, lastName, email, phone,
                country, city, address, programCode, activationCode, programVersion, isFull);

            MailData data = new MailData();
            data.Add("First Name", firstName);
            data.Add("Last Name", lastName);
            data.Add("Email", email);
            data.Add("Phone", phone);
            data.Add("Country", country);
            data.Add("City", city);
            data.Add("Address", address);
            data.Add("Program Key", programCode);
            data.Add("Activation Key", activationCode);
            data.Add("Program Version", programVersion);
            data.Add("Mode", isFull ? "FULL" : "FREE");
            Mailer.MailNotify("Activation", data);

        }
    }
}