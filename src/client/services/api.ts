const foo = async (): Promise<string> => {
	const response = await fetch(`${API_BASE_URL}/foo`);
	const content = response.text();

	return content;
};

export { foo };
