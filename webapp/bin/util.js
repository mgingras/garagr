var isValidPhoneNumber = function(phoneNumber) {
    var error = '';
    var stripped = phoneNumber.replace(/[\(\)\.\-\ ]/g, '');

   if (phoneNumber === '') {
        error = 'You didn\'t enter a phone number.';
    } else if (isNaN(parseInt(stripped))) {
        error = 'The phone number contains illegal characters.';
    } else if (!(stripped.length == 10)) {
        error = 'The phone number is the wrong length. Make sure you included an area code.';
    }
    return error.length === 0;
}

module.exports = {
    validatePhone: isValidPhoneNumber
}
