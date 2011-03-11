<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ContactUsForm.ascx.cs" Inherits="PhotoDBUserControls.ContactUsForm" %>

<div class="form">
	<div class="row required">
        <div class="row_label" >First Name:<span title="This field is required to fill." >*</span></div>
        <input type="text" class="standartInput" id="name" maxlength="100" />
    </div>
	<div class="row required">
        <div class="row_label" >Last Name:<span title="This field is required to fill." >*</span></div>
        <input type="text" class="standartInput" id="Text1" maxlength="100" />
    </div>
    <div class="row required">
        <div class="row_label">E-mail:<span title="This field is required to fill.">*</span></div>
        <input type="text" class="standartInput" id="mail" />
    </div>
    <div class="row required">
        <div class="row_label">Organization:<span title="This field is required to fill.">*</span></div>
        <input type="text" class="standartInput" id="Text2" />
    </div>
    <div class="row optional">
        <div class="row_label">Theme:<span>&nbsp;</span></div>
        <input type="text" class="standartInput" id="theme" />
    </div>
    <div class="row required">
        <div class="row_label">Text:<span title="This field is required to fill.">*</span></div>
        <input type="text" class="standartInput" id="text" />
    </div>
    <div class="row">
        <input type="button" class="standartBtn" value="Send" />
    </div>
</div>