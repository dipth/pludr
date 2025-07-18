// Hashes the given input string using the SHA-256 algorithm.
// @param {string} input - The input string to hash.
// @returns {Promise<string>} The SHA-256 hash of the input string.
export async function sha256(input) {
  const encoder = new TextEncoder()
  const data = encoder.encode(input.trim())
  const hashBuffer = await crypto.subtle.digest("SHA-256", data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, "0")).join("")
}
