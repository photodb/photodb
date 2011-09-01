using System;
using PhotoDBActivation;
using PhotoDBUserControls.Classes;

namespace PhotoDBUserControls
{
    public partial class BuyForm : UmbracoUserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                btnSubmit.Text = GetProperty("submitText");
                txtAppCode.Text = Request[Constants.QueryString.ActivationCode] ?? String.Empty;
                hvProgramVersion.Value = Request[Constants.QueryString.ProgramVersion] ?? String.Empty;
                UpdateValidators();
            }
        }

        private void UpdateValidators()
        {
            string errorMessage = GetProperty("requiredText");
            string incorrectFormat = GetProperty("invalidFormatText");

            rfvFirstName.ErrorMessage = String.Format(errorMessage, GetProperty("firstNameText"));
            rfvLastName.ErrorMessage = String.Format(errorMessage, GetProperty("lastNameText"));
            rfvEmail.ErrorMessage = String.Format(errorMessage, GetProperty("emailText"));
            revEmail.ErrorMessage = String.Format(incorrectFormat, GetProperty("emailText"));
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (Page.IsValid)
            {
                string programKey = txtAppCode.Text;
                string firstName = txtFirstName.Text;
                string lastName = txtLastName.Text;
                string email = txtEmail.Text;
                string phone = txtPhone.Text;
                string country = txtContry.Text;
                string city = txtCity.Text;
                string address = txtAddress.Text;
                string programVersion = hvProgramVersion.Value;

                string freeActivationKey = ActivationHelper.GenerateCommercialActivationNumber(programKey);

                if (firstName.ToUpper() != "TEST")
                {
                    Activation.NotifyActivation(firstName, lastName, email, phone,
                        country, city, address, programKey, freeActivationKey, programVersion, true);
                }

                ltrThankYouMessage.Text = GetProperty("thankYouMessage").Replace("{CODE}", freeActivationKey);
                mvMain.ActiveViewIndex = 1;
            }
        }
    }
}