"""End-to-end smoke test for the Consent Portal, driven by Playwright.

Walks through the main user journey in a real browser:
  1. create a citizen
  2. create a service
  3. grant consent (citizen -> service)
  4. try to grant the same consent again and expect it to be blocked
  5. revoke the consent and check the "Revoked" badge
  6. delete the test data again (unless --keep is passed)

Run it against a local server (bin/rails server):
    python script/playwright/consent_flow.py
    python script/playwright/consent_flow.py --headed --slow-mo 500
"""

import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import Page, expect, sync_playwright

SCREENSHOT_DIR = Path(__file__).parent / "screenshots"


def step(message: str) -> None:
    print(f"→ {message}")


def screenshot(page: Page, name: str) -> None:
    SCREENSHOT_DIR.mkdir(exist_ok=True)
    page.screenshot(path=SCREENSHOT_DIR / f"{name}.png", full_page=True)


def create_citizen(page: Page, base_url: str, name: str, email: str) -> str:
    step(f"Creating citizen {name} <{email}>")
    page.goto(f"{base_url}/citizens/new")
    page.get_by_label("Name").fill(name)
    page.get_by_label("Email").fill(email)
    page.get_by_role("button", name="Create Citizen").click()

    expect(page.locator(".flash.notice")).to_have_text("Citizen was successfully created.")
    screenshot(page, "1_citizen_created")
    return page.url


def create_service(page: Page, base_url: str, name: str) -> str:
    step(f"Creating service {name}")
    page.goto(f"{base_url}/services/new")
    page.get_by_label("Name").fill(name)
    page.get_by_label("Description").fill("Created by the Playwright smoke test")
    page.get_by_role("button", name="Create Service").click()

    expect(page.locator(".flash.notice")).to_have_text("Service was successfully created.")
    screenshot(page, "2_service_created")
    return page.url


def submit_consent(page: Page, base_url: str, citizen: str, service: str) -> None:
    page.goto(f"{base_url}/consents/new")
    page.get_by_label("Citizen").select_option(label=citizen)
    page.get_by_label("Service").select_option(label=service)
    page.get_by_role("button", name="Create Consent").click()


def grant_consent(page: Page, base_url: str, citizen: str, service: str) -> None:
    step(f"Granting consent: {citizen} → {service}")
    submit_consent(page, base_url, citizen, service)

    expect(page.locator(".flash.notice")).to_have_text("Consent was successfully created.")
    expect(page.locator(".badge-active")).to_be_visible()
    screenshot(page, "3_consent_granted")


def duplicate_consent_is_blocked(page: Page, base_url: str, citizen: str, service: str) -> None:
    step("Trying to grant the same consent twice (should be blocked)")
    submit_consent(page, base_url, citizen, service)

    expect(page.locator(".errors")).to_contain_text("already has consent from this citizen")
    screenshot(page, "4_duplicate_blocked")


def revoke_consent(page: Page, consent_url: str) -> None:
    step("Revoking the consent")
    page.goto(consent_url)
    page.get_by_role("button", name="Revoke consent").click()

    expect(page.locator(".flash.notice")).to_have_text("Consent revoked.")
    expect(page.locator(".badge-revoked")).to_be_visible()
    expect(page.get_by_role("button", name="Revoke consent")).to_have_count(0)
    screenshot(page, "5_consent_revoked")


def delete_record(page: Page, url: str) -> None:
    page.goto(url)
    page.get_by_role("button", name="Delete").click()
    expect(page.locator(".flash.notice")).to_contain_text("successfully destroyed")


def run(base_url: str, headed: bool, slow_mo: int, keep: bool) -> None:
    stamp = int(time.time())
    citizen_name = f"Playwright User {stamp}"
    citizen_email = f"playwright+{stamp}@example.com"
    service_name = f"Playwright Service {stamp}"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=not headed, slow_mo=slow_mo)
        page = browser.new_page()
        # Delete buttons ask "Are you sure?" via Turbo; accept those dialogs.
        page.on("dialog", lambda dialog: dialog.accept())

        try:
            citizen_url = create_citizen(page, base_url, citizen_name, citizen_email)
            service_url = create_service(page, base_url, service_name)

            grant_consent(page, base_url, citizen_name, service_name)
            consent_url = page.url

            duplicate_consent_is_blocked(page, base_url, citizen_name, service_name)
            revoke_consent(page, consent_url)

            if keep:
                step("Keeping test data (--keep)")
            else:
                # Citizen and Service both use dependent: :destroy, so the consent goes too.
                step("Cleaning up test data")
                delete_record(page, citizen_url)
                delete_record(page, service_url)
        except Exception:
            screenshot(page, "failure")
            print(f"✗ Failed on {page.url}. See {SCREENSHOT_DIR / 'failure.png'}", file=sys.stderr)
            raise
        finally:
            browser.close()

    print(f"✓ All steps passed. Screenshots in {SCREENSHOT_DIR}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Consent Portal end-to-end smoke test")
    parser.add_argument("--base-url", default="http://localhost:3000")
    parser.add_argument("--headed", action="store_true", help="show the browser window")
    parser.add_argument("--slow-mo", type=int, default=0, help="delay between actions, in ms")
    parser.add_argument("--keep", action="store_true", help="don't delete the test data afterwards")
    args = parser.parse_args()

    run(args.base_url.rstrip("/"), args.headed, args.slow_mo, args.keep)


if __name__ == "__main__":
    main()
