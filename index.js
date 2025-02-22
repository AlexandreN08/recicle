const admin = require('firebase-admin');
const serviceAccount = require('./lib/config/reciclar-23c9f-dcd0a2b18c9a.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Agora você pode usar o Firebase Admin SDK para interagir com os serviços do Firebase