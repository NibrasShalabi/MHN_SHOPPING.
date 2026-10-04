const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./mhn-shopping-firebase-adminsdk-fbsvc-ec64a87e8c.json');

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore('default');
async function seed() {
  await db.collection('categories').doc('cat1').set({
    name: 'تجريبي',
    scope: 'store',
    filters: [],
  });

  await db.collection('products').doc('prod1').set({
    name: 'منتج تجريبي',
    categoryId: 'cat1',
    filterId: null,
    price: 10.0,
    stock: 50,
    isOrderable: true,
    isNew: true,
    imageUrls: [],
    pricing: 'money',
    discountPercentage: null,
    discountEndTime: null,
    createdAt: new Date(),
  });

  console.log('✓ Done');
  process.exit(0);
}

seed().catch(console.error);
async function seed() {
  // config/loyaltyRules
  await db.collection('config').doc('loyaltyRules').set({
    purchaseRuleEnabled: true,
    purchaseIsPercentage: false,
    purchaseValue: 1,
    appRatingRuleEnabled: true,
    appRatingPoints: 50,
    suggestionRuleEnabled: true,
    suggestionPoints: 30,
    expiryEnabled: false,
    expiryMonths: 12,
    minRedemption: 100,
  });

  // sizeSets
  await db.collection('sizeSets').doc('clothing_std').set({
    name: 'ملابس (قياسي)',
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
  });

  // paletteColors
  await db.collection('paletteColors').doc('black').set({
    name: 'أسود',
    value: 0xFF1A1A1A,
  });

  // fitnessPrograms
  await db.collection('fitnessPrograms').doc('hp1').set({
    title: 'إدارة الجسم',
    intro: 'برنامج مخصص لإدارة الوزن والتغذية.',
    coachWhatsappUrl: 'https://wa.me/963900000000',
    suggestedPrograms: [],
    order: 1,
    fields: [
      { id: 'age', label: 'العمر', type: 'number', isRequired: true, options: [] },
      { id: 'weight', label: 'الوزن', type: 'number', isRequired: true, options: [] },
    ],
  });

  console.log('✓ Done');
  process.exit(0);
}