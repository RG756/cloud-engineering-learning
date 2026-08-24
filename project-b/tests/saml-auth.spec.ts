import { test, expect } from '@playwright/test';
import * as dotenv from 'dotenv';
import * as path from 'path';

// .env を読み込む
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const COGNITO_HOSTED_UI = process.env.COGNITO_HOSTED_UI!;
const CLIENT_ID = process.env.COGNITO_CLIENT_ID!;
const CALLBACK_URL = process.env.CALLBACK_URL!;
const USERNAME = process.env.TEST_USERNAME!;
const PASSWORD = process.env.TEST_PASSWORD!;

test('SAML認証フロー：Entra IDログイン → ?code= 取得', async ({ page }) => {
  // Step 1: Cognito Hosted UI にアクセス
  const loginUrl =
    `${COGNITO_HOSTED_UI}/oauth2/authorize` +
    `?client_id=${CLIENT_ID}` +
    `&response_type=code` +
    `&scope=openid+email+profile` +
    `&redirect_uri=${encodeURIComponent(CALLBACK_URL)}`;

  await page.goto(loginUrl);

  // Step 2: "Sign in with EntraID" ボタンをクリック
  await page.getByRole('button', { name: /EntraID/i }).click();

  // Step 3: Entra ID ログイン画面でメールアドレスを入力
  await page.getByPlaceholder('Email, phone, or Skype').fill(USERNAME);
  await page.getByRole('button', { name: 'Next' }).click();

  // Step 4: パスワードを入力
  await page.getByPlaceholder('Password').fill(PASSWORD);
  await page.getByRole('button', { name: 'Sign in' }).click();

　// Step 5: "Stay signed in?" → No（日本語環境では「いいえ」）
　const noButton = page.getByRole('button', { name: /^(No|いいえ)$/ });
  if (await noButton.isVisible({ timeout: 5000 }).catch(() => false)) {
    await noButton.click();
  }

  // Step 6: コールバック URL に ?code= が含まれることを確認
  await page.waitForURL(/example\.com\/callback\?code=/, { timeout: 15000 });
  expect(page.url()).toContain('?code=');

  console.log('✅ 取得した URL:', page.url());
});