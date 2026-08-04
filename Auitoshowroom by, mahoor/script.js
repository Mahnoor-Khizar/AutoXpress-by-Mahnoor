const fuelTypes = ["Petrol", "Diesel", "Hybrid"];
const carImages = [
  "michail-dementiev-OkqN6P-6fQM-unsplash.jpg",
  "martin-katler-x5zAl7WI6u4-unsplash.jpg",
  "karthegan-padmanaban-pcLPbXpNBL8-unsplash.jpg",
  "hyundai-motor-group-3R-0nBOlaOc-unsplash.jpg",
  "jake-fagan-fnE8McnNSIc-unsplash.jpg",
  "david-von-diemar-VEKfdMF8zNQ-unsplash.jpg"
];
const cars = Array.from({ length: 12 }, (_, i) => {
  const makes = ["Toyota", "Honda", "Hyundai", "Suzuki", "Kia"];
  const models = ["Corolla", "Civic", "Elantra", "Swift", "Sportage"];
  const make = makes[i % makes.length];
  const model = models[i % models.length];
  return {
    make,
    model,
    year: 2020 + (i % 6),
    price: 30 + (i % 10) * 5,
    fuelType: fuelTypes[i % fuelTypes.length],
    image: carImages[i % carImages.length] 
  };
});
  function renderCars(list) {
    const container = document.getElementById("carGrid");
    container.innerHTML = "";
    list.forEach(car => {
      const col = document.createElement("div");
      col.className = "col-lg-3 col-md-4 col-sm-6 mb-4";
      col.innerHTML = `
          <div class="car-card h-100" onclick="buyCar('${car.make} ${car.model}')">...
          <img src="${car.image}" class="card-img-top" alt="${car.make} ${car.model}">
          <div class="card-body">
            <h5 class="card-title">${car.make} ${car.model}</h5>
            <p class="card-text">${car.year} | Rs. ${car.price} Lacs</p>
          </div>
        </div>`;
      container.appendChild(col);
    });
  }
  
  function applyFilters() {
    const brand = document.getElementById("brandFilter").value;
    const sort = document.getElementById("sortSelect").value;
  
    let filtered = [...cars];
    if (brand) filtered = filtered.filter(c => c.make === brand);
  
    if (sort === "priceAsc") filtered.sort((a, b) => a.price - b.price);
    if (sort === "priceDesc") filtered.sort((a, b) => b.price - a.price);
    if (sort === "yearDesc") filtered.sort((a, b) => b.year - a.year);
  
    renderCars(filtered);
  }
  
  function buyCar(name) {
    document.getElementById("selectedCarName").innerText = `You're about to purchase: ${name}`;
    new bootstrap.Modal(document.getElementById("buyModal")).show();
  }
  
  function subscribeNewsletter(e) {
    e.preventDefault();
    const name = document.getElementById("nameInput")?.value || "User";
    const email = document.getElementById("emailInput")?.value || document.getElementById("footerEmail")?.value;
    if (!email.includes("@")) {
      alert("Enter a valid email.");
      return;
    }
    alert(`Thank you, ${name}! You've subscribed.`);
  }
  
  document.getElementById("brandFilter").addEventListener("change", applyFilters);
  document.getElementById("sortSelect").addEventListener("change", applyFilters);
  window.onload = () => renderCars(cars);
function openChatBox() {
    document.getElementById('chatBox').style.display = 'block';
  }
  
  function closeChatBox() {
    document.getElementById('chatBox').style.display = 'none';
  }
  