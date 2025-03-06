const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "alexandrenecher@gmail.com", // Substitua pelo seu e-mail
    pass: "Conput@dorand22", // Substitua pela sua senha ou senha de app
  },
});

exports.sendEmail = functions.https.onCall((data, context) => {
  const {email, subject, message} = data;

  const mailOptions = {
    from: "seu-email@gmail.com",
    to: email,
    subject: subject,
    text: message,
  };

  return transporter.sendMail(mailOptions)
    .then(() => {
      return {success: true};
    })
    .catch((error) => {
      console.error("Erro ao enviar e-mail:", error);
      throw new functions.https.HttpsError("internal", "Erro ao enviar e-mail");
    });
});