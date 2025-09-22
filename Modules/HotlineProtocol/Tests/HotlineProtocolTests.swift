import Testing

@Test
func testTrue() async throws {
	var yes = true
	#expect(yes == true)
}
