import { FC, useState } from "react";
import * as api from "../services/api.js";

const Main: FC = () => {
	const [message, setMessage] = useState<string>();
	const handleClick = (): Promise<string> => api.foo();

	return (
		<div>
			<h1>Hello world!</h1>
			<button onClick={handleClick}>Foo</button>
			{message}
		</div>
	);
};

export default Main;
