if ( this.data.successMessage ) {
    // use new API to show the success message if any that came from the dialog
    apex.message.showPageSuccess(this.data.successMessage.text);
    setTimeout(function(){apex.message.hidePageSuccess();}, 6000);
}