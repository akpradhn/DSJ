import requests
from bs4 import BeautifulSoup

def get_amazon_details(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    }
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        return None

    soup = BeautifulSoup(response.content, 'html.parser')

    # Find the price (these selectors may change; inspect the page if not found)
    price = None
    price_selectors = [
        ('span', {'id': 'priceblock_dealprice'}),
        ('span', {'id': 'priceblock_ourprice'}),
        ('span', {'id': 'priceblock_saleprice'}),
        ('span', {'class': 'a-offscreen'})
    ]
    for tag, attrs in price_selectors:
        price_tag = soup.find(tag, attrs)
        if price_tag:
            price = price_tag.get_text(strip=True)
            break

    # Find the discount (if available)
    discount = None
    discount_tag = soup.find('span', {'class': 'a-letter-space'})
    if not discount_tag:
        # Alternative selectors for discount or savings
        discount_tag = soup.find('td', class_="a-span12 a-color-price a-size-base priceBlockSavingsString")
    if discount_tag:
        discount = discount_tag.get_text(strip=True)
    else:
        # Sometimes discount/savings is in the "You Save" field
        savings_tag = soup.find('td', text=lambda t: t and "You Save" in t)
        if savings_tag and savings_tag.find_next('td'):
            discount = savings_tag.find_next('td').get_text(strip=True)

    return {'price': price, 'discount': discount}

# Example usage: replace with your target Amazon product URL
amazon_url = 'https://www.amazon.com/dp/PRODUCT_ASIN'
details = get_amazon_details(amazon_url)
print(details)
