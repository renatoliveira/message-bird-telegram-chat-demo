const parseError = (error) => {
  let errorMessage = error.body.message ? error.body.message : "";

  if (error.body.fieldErrors) {
    Object.keys(error.body.fieldErrors).forEach((fieldName) => {
      let fieldMessages = error.body.fieldErrors[fieldName];
      if (fieldMessages) {
        fieldMessages.forEach((fieldMessage) => {
          errorMessage += fieldMessage.message + "; ";
        });
      }
    });
  }

  return errorMessage;
};

export { parseError };
