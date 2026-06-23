-- Auto-generated seed SQL from backend/data/db.json

insert into public.users ("id", "name", "email", "password_hash", "role", "created_at", "updated_at")
values
  ('usr_36fd28a2d811', 'Forever Admin', 'admin@forever.com', '$2b$10$BHSSMb5g.OFpII5F1XLkVOQuN5TeXZ23nhARiUTsr5WFKbmqwZl7q', 'admin', '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z')
on conflict (id) do nothing;

insert into public.products ("id", "name", "description", "price", "currency", "category", "trend", "image", "in_stock", "created_at", "updated_at")
values
  ('prd_avocado_soap', 'Avocado Face & Body Soap', 'Gentle cleansing soap with moisturizing avocado extracts.', 299, 'INR', 'Personal Care', 'up', 'images/Avocado Face & Body Soap.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_bee_honey', 'Forever Bee Honey', 'Natural honey for daily nutrition and energy support.', 499, 'INR', 'Nutrition', 'up', 'images/Forever Bee Honey.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_deep_moisturizer', 'Deep Moisturizing Cream', 'Hydrating cream for dry skin and all-weather protection.', 799, 'INR', 'Skin Care', 'down', 'images/Deep Moisturizing Cream.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_toothgel', 'Forever Bright Toothgel', 'Aloe-based toothgel for fresh breath and oral care.', 349, 'INR', 'Personal Care', 'stable', 'images/Forever Bright Toothgel.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_cooling_lotion', 'Aloe Cooling Lotion', 'Cooling lotion to soothe skin post sun exposure.', 599, 'INR', 'Skin Care', 'down', 'images/Aloe Cooling Lotion.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_body_wash', 'Aloe Body Wash', 'Refreshing aloe body wash for daily gentle cleansing.', 449, 'INR', 'Personal Care', 'up', 'images/Aloe Body Wash.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_aloe_vera_gel', 'Forever Aloe Vera Gel', 'Inner leaf aloe vera drink that supports daily wellness and digestion.', 1899, 'INR', 'Nutrition', 'up', 'https://cdn.foreverliving.com/content/products/images/forever_aloe_vera_gel__pd_main_512_X_512_1730754836654.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_freedom', 'Forever Freedom', 'Aloe-based drink with glucosamine and chondroitin for active lifestyle support.', 2899, 'INR', 'Nutrition', 'up', 'https://cdn.foreverliving.com/content/products/images/forever_freedom__pd_main_512_X_512_1611251005788.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_bee_pollen', 'Forever Bee Pollen', 'Natural bee pollen supplement for nutrition and energy support.', 1499, 'INR', 'Nutrition', 'up', 'https://cdn.foreverliving.com/content/products/images/forever_bee_pollen__pd_main_512_X_512_1649278499431.jpg', true, '2026-03-09T04:00:24.068Z', '2026-03-09T04:00:24.068Z'),
  ('prd_bee_propolis', 'Forever Bee Propolis', 'Bee propolis chewable supplement to support daily immune wellness.', 2399, 'INR', 'Nutrition', 'stable', 'https://cdn.foreverliving.com/content/products/images/forever_bee_propolis__pd_main_512_X_512_1649278429705.jpg', true, '2026-03-12T03:34:26.691Z', '2026-03-12T03:34:26.691Z'),
  ('prd_royal_jelly', 'Forever Royal Jelly', 'Royal jelly dietary supplement for nutritional support and vitality.', 2599, 'INR', 'Nutrition', 'stable', 'https://cdn.foreverliving.com/content/products/images/forever_royal_jelly__pd_category_256_X_256_1649278724703.jpg', true, '2026-03-12T03:34:30.516Z', '2026-03-12T03:34:30.516Z'),
  ('prd_garcinia_plus', 'Forever Garcinia Plus', 'Garcinia and chromium based supplement for weight-management routines.', 2499, 'INR', 'Nutrition', 'up', 'https://cdn.foreverliving.com/content/products/images/forever_garcinia_plus__pd_main_512_X_512_1611596473456.jpg', true, '2026-03-12T03:34:35.056Z', '2026-03-12T03:34:35.056Z')
on conflict (id) do nothing;

insert into public.chat_faqs ("id", "question", "answer", "created_at", "updated_at")
values
  ('faq_join', 'How to join?', 'You can join Forever by contacting us through the support team.', now(), now()),
  ('faq_investment', 'Is there any investment?', 'No big investment is required to get started.', now(), now()),
  ('faq_orders', 'How can I track my order?', 'Go to My Orders in your account to see current order status.', now(), now())
on conflict (id) do nothing;

