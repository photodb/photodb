<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="BuyForm.ascx.cs" Inherits="PhotoDBUserControls.BuyForm" %>

<asp:MultiView runat="server" ID="mvMain" ActiveViewIndex="0">
    <asp:View runat="server" ID="vForm">

        <div class="validation_summary">
            <asp:ValidationSummary runat="server" ID="vsContactUs" ShowMessageBox="false" ShowSummary="true"
                        DisplayMode="List" CssClass="red" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvFirstName" ControlToValidate="txtFirstName" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvLastName" ControlToValidate="txtLastName" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvEmail" ControlToValidate="txtEmail" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RegularExpressionValidator runat="server"
                        ID="revEmail"   
                        ControlToValidate="txtEmail" Display="None"  
                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                        SetFocusOnError="true" ValidationGroup="vgContactUs"/>
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvOrganization" ControlToValidate="txtOrganization" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvMessageText" ControlToValidate="txtMessageText" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgContactUs" />
        </div>
        
        <div class="form">
	        <div class="row required">
                <div class="row_label" ><%= GetProperty("firstNameText") %>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtFirstName" CssClass="standartInput" MaxLength="100" />
            </div>
	        <div class="row required">
                <div class="row_label" ><%= GetProperty("lastNameText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtLastName" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("emailText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtEmail" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("phoneText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtPhone" CssClass="standartInput" MaxLength="20" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("countryText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtContry" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("cityText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtCity" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("addressText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtAddress" CssClass="standartInput" MaxLength="200" />
            </div>
        </div>

    </asp:View> 
    <asp:View runat="server" ID="vThankYouMessage">
        <asp:Literal runat="server" ID="ltrThankYouMessage" Mode="PassThrough" />
    </asp:View>
</asp:MultiView>