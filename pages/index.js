import { useEffect, useState } from "react";
import { db } from "../utils/firebase";

export default function Home() {
  const [items, setItems] = useState([]);

  useEffect(() => {
    const fetchItems = async () => {
      const snapshot = await db
        .collection("items")
        .orderBy("createdAt", "desc")
        .get();

      const itemsData = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      setItems(itemsData);
    };

    fetchItems();
  }, []);

  return (
    <div className="container mx-auto px-4">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {items.map((item) => (
          <div key={item.id} className="border rounded-lg p-4">
            <img
              src={item.imageUrl}
              alt={item.title || "Item image"}
              className="w-full h-48 object-cover rounded-lg"
            />
            {/* Add other item details as needed */}
          </div>
        ))}
      </div>
    </div>
  );
}
